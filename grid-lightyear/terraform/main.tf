variable "functionapp" {
    type = string
    default = "../src/ElmStreet/bin/Release/netcoreapp3.1/publish.zip"    
}



# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-grid-lightyear-wu2"
  location = "westus2"
  tags = {
        Environment = "Infinity and Beyond"
        Team = "grid-life"
    }
}

resource "azurerm_storage_account" "infinity" {
  name                     = "stinfinitywu2"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_application_insights" "watcher" {
  name                = "appi-watcher-wu2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# no support for linking to app insights yet - https://github.com/terraform-providers/terraform-provider-azurerm/issues/7667
# resource "azurerm_log_analytics_workspace" "story" {
#   name                = "log-story-wu2"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   sku                 = "Free"
# }

output "instrumentation_key" {
  value = azurerm_application_insights.watcher.instrumentation_key
}

output "app_id" {
  value = azurerm_application_insights.watcher.app_id
}

resource "azurerm_eventgrid_domain" "grid" {
  name = "evgd-buzz-grid-wu2"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = { 
    Environment = "Infinity and Beyond"
    Team = "grid-life"
  }  
}

resource "azurerm_eventgrid_domain_topic" "toys" { 
  name = "evgt-andys-toys"
  domain_name = azurerm_eventgrid_domain.grid.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_eventgrid_domain_topic" "abused_toys" { 
  name = "evgt-abused-toys"
  domain_name = azurerm_eventgrid_domain.grid.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_app_service_plan" "plan" {
  name                = "plan-grid-wu2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "F1"
  }
}

resource "azurerm_storage_container" "deployments" { 
  name = "function-releases"
  storage_account_name = azurerm_storage_account.infinity.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "appcode" { 
  name = "${base64encode(filesha256(var.functionapp))}.zip"
  storage_account_name = azurerm_storage_account.infinity.name
  storage_container_name = azurerm_storage_container.deployments.name
  type = "Block"
  source = var.functionapp
}

data "azurerm_storage_account_sas" "sas" {
    connection_string = azurerm_storage_account.infinity.primary_connection_string
    https_only = true
    start = "2021-01-01"
    expiry = "2021-12-31"
    resource_types {
        object = true
        container = false
        service = false
    }
    services {
        blob = true
        queue = false
        table = false
        file = false
    }
    permissions {
        read = true
        write = false
        delete = false
        list = false
        add = false
        create = false
        update = false
        process = false
    }
}

resource "azurerm_function_app" "elm-street" { 
  name = "func-sid-wu2"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  version = "~3"
  storage_account_name = azurerm_storage_account.infinity.name
  storage_account_access_key = azurerm_storage_account.infinity.primary_access_key
  app_settings = {    
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.watcher.instrumentation_key
    SCALE_CONTROLLER_LOGGING_ENABLED = "AppInsights:verbose"
    HASH = base64encode(filesha256(var.functionapp))
    WEBSITE_RUN_FROM_PACKAGE = "${azurerm_storage_blob.appcode.url}${data.azurerm_storage_account_sas.sas.sas}"
    MyEventGridTopicUriSetting = azurerm_eventgrid_domain.grid.endpoint
    MyEventGridTopicKeySetting = azurerm_eventgrid_domain.grid.primary_access_key
  }
}


# Used to add a delay to prevent the subscriptions failing while waiting on specific
# function being created
resource "time_sleep" "wait_60_seconds" {
  depends_on = [ azurerm_function_app.elm-street ]
  create_duration = "60s"
}


resource "azurerm_eventgrid_event_subscription" "sids-room" {
  depends_on = [ time_sleep.wait_60_seconds]
  name = "sids-room"
  scope = azurerm_eventgrid_domain_topic.toys.id
  azure_function_endpoint {
    function_id = "${azurerm_function_app.elm-street.id}/functions/sid"
  }
}


resource "azurerm_eventgrid_event_subscription" "andys-room" {
  depends_on = [ time_sleep.wait_60_seconds]
  name = "andys-room"
  scope = azurerm_eventgrid_domain_topic.abused_toys.id
  azure_function_endpoint {
    function_id = "${azurerm_function_app.elm-street.id}/functions/andy"
  }
}

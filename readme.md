# Event Buzz

    Eventing to infinity and beyond. 

    A basic set of event based setups where I'll be setting up infrastructure using terraform and sending a blast of events into each and monitoring how they perform under different loads. The results should give an indication of when it's a good idea to switch between the different levels of event or message based infrastructure for your specific scenario. 

# Prescripts
    
    
    I used windows 10 for this setup and [chocolatey](https://chocolatey.org/) to download and update my tools. The following commands should get you in a good place for running terraform and this demo. If you already have the tools installed you can run `upgrade` rather than `install`. You'll likely want to be running the latest versions of each tool but I've included `chocolatey-install.ps1` which installs chocolatey and specifies the specific versions used when making this demo.

    ```
        choco upgrade chocolatey        
        
        choco install dotnetcore        
        choco install dotnetcore-sdk   
        choco install azure-functions-core-tools
        choco install azure-cli
        choco install terraform
    ```

# Infrastructure Decisions

    ## Event Grid
        Event grid was setup with eventgridschema, the reason for this was that at the time of writing azure functions binding didn't support the `CloudEventSchemaV1_0` option. If support had existed I would have gone with that option to get a more standardisez schema. 

# Getting started

```
    dotnet publish
    Compress-Archive -path .\bin\Release\netcoreapp3.1\publish\* -DestinatiouPath .\bin\Release\netcoreapp3.1\publish.zip
```

# Resources

    List of resources used when generating this demo. 

    * https://chocolatey.org/
    * https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    * https://adrianhall.github.io/typescript/2019/10/23/terraform-functions/
    * 
# Installs chocolatey if it hasn't already been installed and then installs the azure-cli and terraform. 
# Installation requires admin and will require you to restart powershell to get access to commands.

Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

chocolatey install dotnetcore --version="3.1.12" -y
chocolatey install dotnetcore-sdk --version="3.1.406" -y
chocolatey install azure-functions-core-tools --version="3.0.3284" -y
chocolatey install azure-cli --version="2.19.1" -y
chocolatey install terraform --version="0.14.6" -y

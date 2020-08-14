# Set up Azure Data Science VM as Shiny Server

In this architecture, we deploy an Azure Data Science VM (DSVM) to:

* Host Shiny Server
* Run R scripts using the azuremlsdk package

This document describes the process of setting up the DSVM, which is currently a series of manual steps.
I plan to automate this process in the future.

## Deployment Process

1. Fork the mlops-r-gha reporitory.

1. Add secrets to the repository

1. Deploy Azure DSVM as "shinyserver". Use "azureuser" for the default account. Note its IP address, you'll need it later. Instructions: TODO

1. Enable SSH access for "azureuser" account.

1. SSH to shinyserver.

1. (OPTIONAL) Suppress login banner. This makes the Actions logs easier to read.  
```bash
touch .hushlogin
```

7. Open port 3838 on shinyserver by adding a rule to the network security group. Instructions: TODO

1. Install shiny-server. [Download for Ubuntu here](https://rstudio.com/products/shiny/download-server/ubuntu/). Visit the default Shiny homepage at http://SHINYSERVERIP:3838/

1. Replace /etc/shiny-server/shiny-server.conf with the file in this repository. This configures Shiny to deliver a single application from the "mlops-r-gha/accident-app" folder, and we can update files here via the configured SSH.







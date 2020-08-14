# Set up Azure Data Science VM as Shiny Server

In this architecture, we deploy an Azure Data Science VM (DSVM) to:

* Host Shiny Server
* Run R scripts using the azuremlsdk package

This document describes the process of setting up the DSVM, which is currently a series of manual steps.
I plan to automate this process in the future.

NOTE: Using the DSVM is not a requirement, it's just convenient because many of the tools we need (git, R, Python etc.) come pre-installed. You can use any VM or even an on-premises server, as long as it supports shiny server. Here are instructions for [configuring a basic VM on Azure](https://canovasjm.netlify.app/2020/01/08/deploy-you-own-shiny-server-on-azure/).

## Deployment Process

1. Fork this `mlops-r-gha` repository to your GitHub account

1. (OPTIONAL) If you wish to use an existing Azure ML workspace, edit `.cloud/.azure/workspace.json` accordingly, otherwise a new workspace will be created for you.

1. Add the AZURE_CREDENTIALS secret to the repository, as described step 3 of [this file](https://github.com/machine-learning-apps/ml-template-azure/blob/master/README.md).

1. Deploy an instance of the Azure Data Science Virtual Machine for Ubuntu. Call it "shinyserver". Use "azureuser" for the default account, and [enable SSH access](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys?WT.mc_id=aiml-2093-davidsmi). Note the server IP address, you'll need it later (we will refer to it as SHINYSERVERIP below). [Detailed Instructions](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/dsvm-ubuntu-intro?WT.mc_id=aiml-2093-davidsmi)

1. Open port 3838 on shinyserver by adding a rule to the network security group that was created when you set up the DSVM. Also verify that Port 22 (SSH) is not blocked by the rules. [Detailed Instructions](https://docs.microsoft.com/azure/virtual-network/manage-network-security-group?WT.mc_id=aiml-2093-davidsmi). 

1. Add the SHINYKEY secret to your forked repo in GitHub with the private SSH key needed to access shinyserver. Also add SHINYHOST with the SHINYSERVERIP address, set SHINYUSERNAME to `azureuser`, and SHINYPORT to `3838`.

1. SSH to shinyserver: `ssh azureuser@SHINYSERVERIP`

1. (OPTIONAL) Suppress login banner. This makes the Actions logs easier to read.  
```bash
touch .hushlogin
```

9. Install shiny-server. [Download for Ubuntu here](https://rstudio.com/products/shiny/download-server/ubuntu/). Visit the default Shiny homepage at http://SHINYSERVERIP:3838/

1. Replace /etc/shiny-server/shiny-server.conf with the file in this repository. This configures Shiny to deliver a single application from the "mlops-r-gha/accident-app" folder, and we can update files here via the configured SSH.

1. Clone the mlops-r-gha repository on shinyserver
```bash
git clone https://github.com/revodavid/mlops-r-gha
```

12. Launch R and install the `azuremlsdk` package from GitHub as described in the [`azuremlsdk` repository](https://github.com/Azure/azureml-sdk-for-r). Don't forget the `azuremlsdk::install_azureml()` step.

13. Trigger the "Train and Deploy Model" GitHub Action in your repository. You can do this by touching a file in the `model` folder, or by browsing the Actions tab and using the "Re-Run Jobs" feature.

14. Wait for Actions to complete successfully, and then try our your Shiny app at https://SHNIYSERVERIP:3838/accident/















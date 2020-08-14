# Set up Azure Data Science VM as Shiny Server

In this architecture, we deploy an Azure Data Science VM (DSVM) to:

* Host Shiny Server
* Run R scripts using the azuremlsdk package

This document describes the process of setting up the DSVM, which is currently a series of manual steps.
I plan to automate this process in the future.

## Deployment Process

1. Deploy Azure DSVM as "shinyserver". Use "azureuser" for the default account. Instructions: TODO

2. Enable SSH access for "azureuser" account.

3. SSH to shinyserver.

4. (OPTIONAL) Suppress login banner. This makes the Actions logs easier to read.
```bash
touch .hushlogin
```

5. Open port 3838 on shinyserver by adding a rule to the network security group. Instructions: TODO

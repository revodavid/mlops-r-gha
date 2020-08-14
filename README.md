# MLOPS with R: An end-to-end process for building machine learning applications

As predictive models and machine learning become key components of production applications in every industry, an end-to-end Machine Learning Operations (MLOPS) process becomes critical for reliable and efficient deployment of applications that depend on R-based models. In this talk, I’ll outline the basics of the DevOps process and focus on the areas where MLOPS diverges. The talk will show the complete process of building and deploying an application driven by a machine learning model implemented with R. We will show the process of developing models, triggering model training on code changes, and triggering the CI/CD process for an application when a new version of a model is registered. We will use the Azure Machine Learning service and the “azuremlsdk” package to orchestrate the model training and management process, but the principles will apply to MLOPS processes generally, especially for applications that involve large amounts of data or require significant computing resources.

## Instructions for replicating the demo

1. Fork this repository.

2. Follow the directions in [ML Ops with GitHub Actions and Azure Machine Learning](https://github.com/machine-learning-apps/ml-template-azure) to:

   * Create a resource group in your Azure subscription. (If you don't have one, create an [Azure Free Subscription](https://azure.microsoft.com/free/?WT.mc_id=aiml-2093-davidsmi) and get $200 in free Azure credits.)
   * Create a service principal
   * Add secrets to your forked repository
   * Configure the `.cloud\.azure\workspace.json` file. You can use an existing Azure ML Workspace, or if none by the specified name exists it will be created for you. 

3. Deploy an Azure Data Science Virtual Machine


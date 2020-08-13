library(azuremlsdk)

library(jsonlite)
AZURE_CREDENTIALS=Sys.getenv("AZURE_CREDENTIALS")
if(nchar(AZURE_CREDENTIALS)==0) stop("No AZURE_CREDENTIALS")

creds <- fromJSON(AZURE_CREDENTIALS)
if(length(creds)==0) stop("Malformed AZURE_CREDENTIALS")

TENANT_ID <- creds$tenantId
SP_ID <- creds$clientId
SP_SECRET <- creds$clientSecret
SUBSCRIPTION_ID <- creds$subscriptionId

workspace.json <- fromJSON(".cloud/.azure/workspace.json")
WSRESOURCEGROUP <- workspace.json$resource_group
WSNAME <- workspace.json$name

register.json <- fromJSON(".cloud/.azure/registermodel.json")
MODEL_FILE_NAME <- register.json$model_file_name ## TODO: Use this
WEBSERVICE_NAME <- register.json$webservice_name ## TODO: Use this

svc_pr <- service_principal_authentication(tenant_id=TENANT_ID,
                                           service_principal_id=SP_ID,
                                           service_principal_password=SP_SECRET)

ws <- get_workspace(WSNAME,
                    SUBSCRIPTION_ID,
                    WSRESOURCEGROUP, auth=svc_pr)

cat("Found workspace\n")

accident_model <- readRDS("outputs/model.rds")

model <- register_model(ws, 
                        model_path = "outputs/model.rds", 
                        model_name = "accidents_gha",
                        description = "Predict probability of auto accident using caret")

cat("Model registered.\n")

## Delete the existing webservice, if it exists
cat("If this is your first deploy, ignore any WebServiceNotFound error that follows.\n")
try({
    old_service <- get_webservice(ws, 'accidents-gha')
    delete_webservice(old_service)
})

## Deploy the updated model

r_env <- r_environment(name = "basic_env")

inference_config <- inference_config(
  entry_script = "accident_predict_caret.R",
  source_directory = ".",
  environment = r_env)

aci_config <- aci_webservice_deployment_config(cpu_cores = 1, memory_gb = 0.5)

aci_service <- deploy_model(ws, 
                        'accidents-gha', 
                        list(model), 
                        inference_config, 
                        aci_config)
wait_for_deployment(aci_service, show_output = TRUE)

cat("Model deployed.\n")

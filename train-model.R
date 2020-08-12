library(azuremlsdk)
print(get_current_run())

cat("Completed package load\n")

library(jsonlite)
AZURE_CREDENTIALS=Sys.getenv("AZURE_CREDENTIALS")

creds <- fromJSON(AZURE_CREDENTIALS)
if(length(creds)==0) stop("Provide AZURE_CREDENTIALS secret.")

cat("gallery endpoint:")
print(creds$galleryEndpointUrl)

TENANT_ID <- creds$tenantId
SP_ID <- creds$clientId
SP_SECRET <- creds$clientSecret
SUBSCRIPTION_ID <- creds$subscriptionId

workspace.json <- fromJSON(".cloud/.azure/workspace.json")
WSRESOURCEGROUP <- workspace.json$resource_group
WSNAME <- workspace.json$name

compute.json <- fromJSON(".cloud/.azure/compute.json")
CLUSTER_NAME <- compute.json$name

svc_pr <- service_principal_authentication(tenant_id=TENANT_ID,
                                           service_principal_id=SP_ID,
                                           service_principal_password=SP_SECRET)

ws <- get_workspace(WSNAME,
                    SUBSCRIPTION_ID,
                    WSRESOURCEGROUP, auth=svc_pr)

cat("Found workspace\n")

## TODO: Get compute cluster from prior step

compute_target <- get_compute(ws, cluster_name = CLUSTER_NAME)
if (is.null(compute_target)) {
  vm_size <- "STANDARD_D2_V2" 
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = CLUSTER_NAME,
                                       vm_size = vm_size,
                                       min_nodes = 0,
                                       max_nodes = 2)

  wait_for_provisioning_completion(compute_target, show_output = TRUE)
}

cat("Found cluster\n")

ds <- get_default_datastore(ws)
target_path <- "accidentdata"

download_from_datastore(ds, target_path=".", prefix="accidentdata")

exp <- experiment(ws, "accident")

est <- estimator(source_directory=".",
                 entry_script = "accident-glm.R",
                 script_params = list("--data_folder" = ds$path(target_path)),
                 compute_target = compute_target)
run <- submit_experiment(exp, est)

download_files_from_run(run, prefix="outputs/")

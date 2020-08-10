library(azuremlsdk)
library(caret)
ws <- load_workspace_from_config()

ds <- get_default_datastore(ws)
target_path <- "accidentdata"

download_from_datastore(ds, target_path=".", prefix="accidentdata")

## Create 2-node compute cluster for training, with auto-scaledown to zero
cluster_name <- "rcluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target)) {
  vm_size <- "STANDARD_D2_V2" 
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = cluster_name,
                                       vm_size = vm_size,
                                       min_nodes = 0,
                                       max_nodes = 2)

  wait_for_provisioning_completion(compute_target, show_output = TRUE)
}

exp <- experiment(ws, "accident")

est <- estimator(source_directory=".",
                 entry_script = "accident-glm.R",
                 script_params = list("--data_folder" = ds$path(target_path)),
                 compute_target = compute_target)
run <- submit_experiment(exp, est)

# plot_run_details(run)

download_files_from_run(run, prefix="outputs/")
accident_model <- readRDS("outputs/model.rds")

model <- register_model(ws, 
                        model_path = "outputs/model.rds", 
                        model_name = "accidents_gha",
                        description = "Predict probability of auto accident using caret")

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

accident.endpoint <- get_webservice(ws,   "accident-pred-caret")$scoring_uri
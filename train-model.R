library(azuremlsdk)

ws <- load_workspace_from_config()

## TODO: Get compute cluster from prior step
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

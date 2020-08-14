library(azuremlsdk)
library(jsonlite)

## Read data from CSV file, clean, and save to .Rd file

nassCDS <- read.csv("nassCDS.csv", 
                     colClasses=c("factor","numeric","factor",
                                  "factor","factor","numeric",
                                  "factor","numeric","numeric",
                                  "numeric","character","character",
                                  "numeric","numeric","character"))
accidents <- na.omit(nassCDS[,c("dead","dvcat","seatbelt","frontal","sex","ageOFocc","yearVeh","airbag","occRole")])
accidents$frontal <- factor(accidents$frontal, labels=c("notfrontal","frontal"))
accidents$occRole <- factor(accidents$occRole)
accidents$dvcat <- ordered(accidents$dvcat, 
                          levels=c("1-9km/h","10-24","25-39","40-54","55+"))

saveRDS(accidents, file="accidents.Rd")

## Upload .Rd file to Azure ML storage

AZURE_CREDENTIALS=Sys.getenv("AZURE_CREDENTIALS")
if(nchar(AZURE_CREDENTIALS)==0) stop("No AZURE_CREDENTIALS")

creds <- fromJSON(AZURE_CREDENTIALS)
if(length(creds)==0) stop("Malformed AZURE_CREDENTIALS")

TENANT_ID <- creds$tenantId
SP_ID <- creds$clientId
SP_SECRET <- creds$clientSecret
SUBSCRIPTION_ID <- creds$subscriptionId

workspace.json <- fromJSON("../.cloud/.azure/workspace.json")
WSRESOURCEGROUP <- workspace.json$resource_group
WSNAME <- workspace.json$name

compute.json <- fromJSON("../.cloud/.azure/compute.json")
CLUSTER_NAME <- compute.json$name

svc_pr <- service_principal_authentication(tenant_id=TENANT_ID,
                                           service_principal_id=SP_ID,
                                           service_principal_password=SP_SECRET)

ws <- get_workspace(WSNAME,
                    SUBSCRIPTION_ID,
                    WSRESOURCEGROUP, auth=svc_pr)

cat("Found workspace\n")

## Upload data file to datastore

ds <- get_default_datastore(ws)
target_path <- "accidentdata"
upload_files_to_datastore(ds,
                          list("./accidents.Rd"),
                          target_path = target_path,
                          overwrite = TRUE)


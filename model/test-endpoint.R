## This file isn't used by the model or the app, but you can use it to check if the endpoint is working

library(httr)

## Run this on the shinyserver, where the /home/azureuser/endpoint.Rd file should be pointing to the endpoint URL
## if not, set it manually by checking the endpoint URL in the Azure ML studio

accident.endpoint <- readRDS("/home/azureuser/endpoint.Rd") # file placed by deploy-model.R

newdata <- data.frame( # valid values shown below
    dvcat="10-24",        # "1-9km/h" "10-24"   "25-39"   "40-54"   "55+"  
    seatbelt="none",      # "none"   "belted"  
    frontal="frontal",    # "notfrontal" "frontal"
    sex="f",              # "f" "m"
    ageOFocc=16,          # age in years, 16-97
    yearVeh=2002,         # year of vehicle, 1955-2003
    airbag="none",        # "none"   "airbag"   
    occRole="pass"        # "driver" "pass"
)

v <- POST(accident.endpoint, body=newdata, encode="json")
cat("Prediction: ")
cat(content(v)[[1]]*100)
cat("\n")


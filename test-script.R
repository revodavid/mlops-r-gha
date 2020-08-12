print(R.version)
SHINYHOST <- Sys.getenv("SHINYHOST")
cat(paste("SHINYHOST: ", SHINYHOST, "\n"))
library(magrittr)
"hello\n" %>% cat
library(azuremlsdk)
print("done")
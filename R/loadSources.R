
cat("\n\n\n")
cat("------------------------------------ \n")
cat(" EXTRACTEUR DE FLUX GTFS TEMPS RÉEL \n")
cat("     ------------------------- \n")
cat("           CIVILIA      \n")
cat("          ----------\n")
cat("Auteur : Xavier Prudent (xprudent@civilia.ca)")
cat("\n\n")


#####################################
## Packages
suppressMessages(library(lubridate))
suppressMessages(library(profvis))
suppressMessages(library(plyr))
suppressMessages(library(tidyr))
suppressMessages(library(dplyr))
suppressMessages(library(stringr))
suppressMessages(library(RProtoBuf))
suppressMessages(library(data.table))
suppressMessages(library(fasttime))
suppressMessages(library(RSQLite))
suppressMessages(library(R.utils))
setOption("dplyr.show_progress",FALSE)
#####################################
## Sources
source("inputs.R")
source("outputs.R")
source("processor.R")
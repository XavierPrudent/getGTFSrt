#!/usr/bin/env Rscript
args = commandArgs(TRUE)
source("loadSources.R")
##
## Check user inputs
checkInputs(args)
##
## Prepare output DB
db.out <- prepareOutputs(args)
while(TRUE){
  ##
  ## Download the gtfs-rt
  GTFSrt.name <- downloadGTFSrt(args)
  ##
  ## Convert to datatable
  GTFSrt.data <- readGTFSrt(args,GTFSrt.name)
  ##
  ## Save to DB
  saveGTFSrt(db.out, GTFSrt.data)
  ##
  ## Wait for 15 sec
  Sys.sleep(15)
}
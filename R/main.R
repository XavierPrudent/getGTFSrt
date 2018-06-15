#!/usr/bin/env Rscript
args = commandArgs(TRUE)

###########################
## Check user inputs
if( length(args) == 0 ){
  cat("\n\n Arguments needed:\n")
  cat("1. web link to gtfs-rt: www.sttr.ca/gtfs/vehiculePosition.pb\n")
  cat("2. Type of gtfs-rt: vehiclePositions / trip_update\n")
  cat("3. output dir for db of gtfs-rt: /root/civilia/db/\n")
  cat("4. gtfs rt proto file: /root/data/gtfs.proto\n\n\n")
  cat("5. path to tool: /root/R/\n\n\n")
  stop()
}
##
## Missing arguments
for( i in 1:5 ){
  if( args[i] == "" ) stop(paste("ERROR: Argument",i,"missing\n"))
}
##
## Missing directory
if( !dir.exists(args[3])) stop("ERROR: Output directory missing")
##
## Summary
cat("\n")
cat("Input arguments:\n")
cat(paste0("Web link .............. ", args[1], "\n"))
cat(paste0("Type of gtfs-rt........ ", args[2], "\n"))
cat(paste0("Output dir for DB ..... ", args[3], "\n"))
cat(paste0("Proto file for gtfs ... ", args[4], "\n"))
cat(paste0("Path to tool....... ... ", args[5], "\n"))
cat("\n")

#####################################
## Sources
source(paste(args[5],"/loadSources.R",sep=""))
source(paste(args[5],"/outputs.R",sep=""))
source(paste(args[5],"/processor.R",sep=""))

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
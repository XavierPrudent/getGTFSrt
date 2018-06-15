#####################################
## Check user inputs
## 1. web link to gtfs-rt: www.sttr.ca/gtfs/vehiculePosition.pb
## 2. Type of gtfs-rt: vehiclePositions / trip_update
## 3. output dir for db of gtfs-rt: /root/civilia/db/
## 4. gtfs rt proto file: /root/data/gtfs.proto
checkInputs <- function(args){
  if( length(args) == 0 ){
    cat("\n\n Arguments needed:\n")
    cat("1. web link to gtfs-rt: www.sttr.ca/gtfs/vehiculePosition.pb\n")
    cat("2. Type of gtfs-rt: vehiclePositions / trip_update\n")
    cat("3. output dir for db of gtfs-rt: /root/civilia/db/\n")
    cat("4. gtfs rt proto file: /root/data/gtfs.proto\n\n\n")
    stop()
  }
  ##
  ## Missing arguments
  for( i in 1:4 ){
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
  cat("\n")
  
}
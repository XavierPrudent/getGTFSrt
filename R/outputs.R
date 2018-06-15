#####################################
## Prepare output database
prepareOutputs <- function(args){
  cat(" ---- Preparing the output DB...\n")
  ##
  ## One database per week per year
  dateToday <- Sys.time()
  attr(dateToday,"tzone") <- "America/Montreal"
  db.period <- paste(year(dateToday),"-w",isoweek(dateToday),sep="")
  ##
  ## DB names
  dbname <- paste0(args[3],"/",args[2], "_",db.period,".db")
  cat(paste0("Output DB ............. ", dbname,"\n"))
  ##
  ## Connect to output databases
  m <- dbDriver("SQLite")
  db.out <- dbConnect(m,dbname=dbname)
  ##
  ## Load proto file
  readProtoFiles(args[4])
  
  return(db.out)
}

#####################################
## Write to database
saveGTFSrt <- function(db.out, GTFSrt.data){
  cat(" ---- Saving the gtfs-rt...\n")
  dbWriteTable(db.out, "sae", GTFSrt.data, row.names = FALSE,append=TRUE)
}
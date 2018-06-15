#!/usr/bin/env Rscript
##
## R libraries
library(data.table)
library(dplyr)
library(stringr)
##
## Check user inputs
args = commandArgs(TRUE)
if( length(args) == 0 ){
  cat("\n\n Arguments needed:\n")
  cat("1. web link to gtfs-plan: www.sttr.ca/gtfs/gtfs.zip\n")
  cat("2. output dir : /root/civilia/gtfs/\n")
  cat("3. abreviation of the transport company : STTR\n")
  stop()
}
##
## Missing arguments
for( i in 1:3 ){
  if( args[i] == "" ) stop(paste("ERROR: Argument",i,"missing\n"))
}
##
## Missing directory
if( !dir.exists(args[2])) stop("ERROR: Output directory missing")
##
## Summary
cat("\n")
cat("Input arguments:\n")
cat(paste0("Web link .............. ", args[1], "\n"))
cat(paste0("Output dir ............ ", args[2], "\n"))
cat(paste0("Abreviation company ... ", args[3], "\n"))
cat("\n")
##
## Create unique file name
GTFS.name <- tempfile(pattern = "file", tmpdir = "/tmp" )
##
## Download the gtfs
download.file(url=args[1], destfile = GTFS.name)
##
## Unzip the gtfs calendar
unzip(GTFS.name, exdir="temp",files="calendar_dates.txt")
##
## Read the calendar
GTFS.cal <- fread("temp/calendar_dates.txt")
##
## Find min and max dates
GTFS.cal <- GTFS.cal %>% mutate( d = str_sub(date,-2,-1),
                                 m = str_sub(date,-4,-3),
                                 y = str_sub(date,-8,-5)) %>%
  mutate(date=as.Date(paste(y,m,d,sep="-")))
date.min <- min(GTFS.cal$date)
date.max <- max(GTFS.cal$date)
cat(paste0("Start date .............. ", date.min, "\n"))
cat(paste0("End date ................ ", date.max, "\n"))
##
## Clean up 
unlink("temp/",recursive=T)
##
## Make the correct name for the GTFS
GTFS.name.new <- paste(args[2],"/GTFS_",args[3],"_",date.min,"_",date.max,".zip",sep="")
##
## If the file does not exist, rename it
if( !file.exists(GTFS.name.new)) {
  cat("New GTFS found\n")
  file.rename(from=GTFS.name, to=GTFS.name.new)
} else{
  cat("Still current GTFS\n")
  unlink(GTFS.name)
}



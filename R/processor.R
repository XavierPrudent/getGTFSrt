
#####################################
## Download the gtfs-rt
downloadGTFSrt <- function(args){
  cat(" ---- Downloading the gtfs-rt...\n")
  ##
  ## Create unique file name
  GTFSrt.name <- tempfile(pattern = "file", tmpdir = "/tmp" )
  ##
  ## Download the gtfs-rt
  download.file(url=args[1], destfile = GTFSrt.name)
  return(GTFSrt.name)
}

#####################################
## Read the gtfs-rt and extract the info for the requests
readGTFSrt <- function(args,GTFSrt.name){
  cat(" ---- Extracting the gtfs-rt...\n")
  ##
  ## Read and check the feed
  GTFSrt <- checkGTFSfeed(GTFSrt.name)
  ##
  ## Extract the tripUpdate infos
  if( args[2] == "trip_update") GTFSrt.data <- read.trip_update(GTFSrt)
  ##
  ## Extract the vehicle info
  if( args[2] == "vehicle") GTFSrt.data <- read.vehicle(GTFSrt)
  return(GTFSrt.data)
}

#####################################
## Read and check the feed
checkGTFSfeed <- function(GTFSrt.name){
  cat(" ---- Reading and checking the gtfs-rt...\n")
  ##
  ## Extract the feed
  GTFSrt.feed <- RProtoBuf::read( transit_realtime.FeedMessage, GTFSrt.name)
  unlink(GTFSrt.name)
  ##
  ## validate FeedMessage
  if(!"transit_realtime.FeedMessage" %in% attributes(GTFSrt.feed))
    stop("FeedMessage must be a FeedMesssage response")
  GTFSrt.feed_idx <- lapply(GTFSrt.feed$entity, function(x) { length(x[[args[2]]]) > 0 })
  timestamp=GTFSrt.feed$header$timestamp
  GTFSrt.feed <- GTFSrt.feed$entity[which(GTFSrt.feed_idx == T)]
  return(list(GTFSrt.feed=GTFSrt.feed, timestamp=timestamp))
}

#####################################
## Read the vehicle feed
read.vehicle <- function(GTFSrt){
  cat(" ---- Reading the gtfs-rt vehicle...\n")
  GTFSrt.feed <- GTFSrt$GTFSrt.feed
  ##
  ## Loop over the trips
  lst <- lapply(GTFSrt.feed, function(x){
    ##
    ## Extract trip, route, stoptimeupdate
    trip_id.x <- x[['vehicle']][['trip']][['trip_id']]
    route_id.x <- x[['trip_update']][['trip']][['route_id']]
    sequence.x <- x[['vehicle']][['current_stop_sequence']]
    stop_id.x <- x[['vehicle']][['stop_id']]
    timestamp.x <- x[['vehicle']][['timestamp']]
    position.x <- x[['vehicle']][['position']]
    lat.y <- position.x[["latitude"]]
    lon.y <- position.x[["longitude"]]
    bearing.y <- position.x[["bearing"]]
    speed.y <- position.x[["speed"]]
    ##
    ## Gather in a dataframe
    dt_vehicle <- data.frame(trip_id = trip_id.x, 
                             route_id = route_id.x,  
                             sequence = sequence.x,
                             stop_id = stop_id.x,
                             timestamp = timestamp.x,
                             lat = lat.y,
                             lon = lon.y,
                             bearing = bearing.y,
                             speed = speed.y)
    return(dt_vehicle)
  })
  ##
  ## non null df
  lst <- lst[!sapply(lst, is.null)] 
  lst <- do.call("rbind", lapply(lst, as.data.frame))
  setDT(lst)
  return(lst)
}
#####################################
## Read the trip_update feed
read.trip_update <- function(GTFSrt){
  cat(" ---- Reading the gtfs-rt trip_update\n")
  timestamp <- GTFSrt$timestamp
  GTFSrt.feed <- GTFSrt$GTFSrt.feed
  ##
  ## Loop over the trips
  lst <- lapply(GTFSrt.feed, function(x){
    ##
    ## Extract trip, route, stoptimeupdate
    trip_id.x <- x[['trip_update']][['trip']][['trip_id']]
    route_id.x <- x[['trip_update']][['trip']][['route_id']]
    direction.x <- x[['trip_update']][['trip']][['direction_id']]
    stop_time_update.x <- x[['trip_update']][['stop_time_update']]
    ##
    ## Loop over stoptimeupdate
    stop_time_update <- lapply(stop_time_update.x, function(y){
      ##
      ## Extract stop id, sequence and delay
      stop_id.y <- y[['stop_id']]
      stop_sequence.y <- y[['stop_sequence']]
      delay.y <- y[['arrival']][['delay']]
      return(data.table::data.table(
        stop_sequence = stop_sequence.y,
        stop_id = stop_id.y,
        delay = delay.y
      ))
    })
    dt_stop_time_update <- data.table::rbindlist(stop_time_update, use.names = T, fill = T)
    dt_stop_time_update[,route_id := route_id.x]
    dt_stop_time_update[,trip_id := trip_id.x]
    dt_stop_time_update[,direction := direction.x]
    return(dt_stop_time_update)
  })
  ##
  ## non null df
  lst <- lst[!sapply(lst, is.null)] 
  lst <- do.call("rbind", lapply(lst, as.data.frame))
  setDT(lst)
  lst[,timestamp := timestamp]
  return(lst)
}

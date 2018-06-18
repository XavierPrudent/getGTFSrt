#!/usr/bin/env Rscript
args = commandArgs(TRUE)

###########################
## Check user inputs
if( length(args) == 0 ){
  cat("\n\n Arguments needed:\n")
  cat("1. Link to sae db\n\n")
  stop()
}
#####################################
## Packages
suppressMessages(library(lubridate))
suppressMessages(library(plyr))
suppressMessages(library(tidyr))
suppressMessages(library(dplyr))
suppressMessages(library(stringr))
suppressMessages(library(data.table))
suppressMessages(library(fasttime))
suppressMessages(library(RSQLite))
suppressMessages(library(R.utils))
suppressMessages(library(plotly))
suppressMessages(library(xts))
setOption("dplyr.show_progress",FALSE)
#####################################
## Colors
civ.col1 <- rgb(60/255, 60/255, 59/255)
civ.col2 <- rgb(145/255, 191/255, 39/255)
civ.axis.col <- list(linecolor = toRGB("lightgrey"),
                     gridcolor = toRGB("darkgrey"),
                     tickcolor = toRGB("darkgrey"),
                     tickfont = list(color="white"),
                     titlefont = list(color="white"))
#####################################
## Connect to database
m <- dbDriver("SQLite")
db.in <- dbConnect(m,dbname=args[1])
d.in <- dbGetQuery(db.in,"SELECT * FROM sae")
#####################################
## Clean database
setDT(d.in)
d.in <- unique(d.in)
##
## Change timestamp
d.in <- d.in %>% 
  mutate(time=as.POSIXct(timestamp, origin="1970-01-01", tz="America/Toronto"))
##
## Cut on we
d.in <- d.in %>% 
  filter(time > as.POSIXct("2018-06-16 05:0:00",tz="America/Toronto"))

d <- d.in %>% 
  group_by(time) %>% 
  summarise(n=n())

plot_ly(data=d, x=~time,y=~n, type="scatter", mode="markers+lines", color=I(civ.col2)) %>%
  layout(xaxis=list(title="Time"), yaxis=list(title="Nb. of measurements")) %>%
  layout(
    yaxis = civ.axis.col,
    xaxis = civ.axis.col,
    plot_bgcolor=civ.col1,
    paper_bgcolor=civ.col1
  )

## Compactify data by time window
all.lines <- unique(d.in$route_id)
plotRoutes <- plot_ly() %>% 
  layout(showlegend = FALSE, 
         yaxis = list(title="Routes ID", categoryarray = all.lines, categoryorder = "array"), 
         xaxis = list(title="Time"))
col.rte <- "#91BF27"

for( i.rte in 1:length(all.lines)){
  ## Extract moments with these lines
  d <- d.in %>% filter(route_id == all.lines[i.rte])
  d.xts <- xts(d$route_id,  order.by=d$time, tz="America/Toronto")
  d.xts <- period.apply(d.xts, endpoints(d.xts, "mins", k=5), unique) 
  d.xts <- data.frame(date=index(d.xts), value=d.xts[,1,drop=T])
  
  if( nrow(d.xts) == 0 ) next
  ## Switch colors
  col.rte <- ifelse(col.rte == "#91BF27", "white", "#91BF27")
  plotRoutes <- plotRoutes %>% add_trace(data=d.xts, 
                                         x=~date,
                                         y=all.lines[i.rte], 
                                         type="scatter",
                                         mode = 'markers', 
                                         marker=list(symbol=1),
                                         color=I(col.rte), 
                                         marker=list(size=10), 
                                         hoverinfo = 'text',
                                         text = paste('Ligne : ', all.lines[i.rte]) )
}
plotRoutes <- plotRoutes %>%
  layout(
    yaxis = civ.axis.col,
    xaxis = civ.axis.col,
    plot_bgcolor=civ.col1,
    paper_bgcolor=civ.col1
  )

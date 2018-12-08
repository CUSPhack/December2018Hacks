###### freegan app dev for nyu cusp hackathon fall 2018 ########

# freegan site location and type data from fallingfruit.org
library(tidyverse)
library(rgdal)
library(sp)

download.file("http://fallingfruit.org/locations.csv.bz2", "sites.csv")
spots <- read.csv("sites.csv", na.strings = c("", " ", "NULL", "NA"), stringsAsFactors = FALSE)

# first filter to manhattan locations using lat/lon coordinates (used bounding box to set min/max)
min.lat <- 40.69558
max.lat <- 40.85551
min.lon <- -74.01611
max.lon <- -73.9035
spots <- spots[spots$lat >= min.lat & spots$lat <= max.lat & spots$lng >= min.lon & spots$lng <= max.lon, ]

# remove entries with no site description and filter down to type = edible dumpster contents
# remove unwanted admin columns like link update
spots <- spots[!is.na(spots$description) & spots$type_ids == 2, -c(7, 8, 9, 14, 15, 16)]

# create site sentiment analysis
spots %<>% mutate(quality = ifelse(grepl("good|great|lots|friendly|fresh|easy|massive amount", description),"good",
ifelse(grepl("bad|secur| locked|inaccessible|chased|rotten|hard|messy|avoid", description),"bad", "neutral"))) %>%
dplyr::select(lat, lng, spot = description, quality, author)


# write data out as spatial points data frame
spotsshp <- spots
coordinates(spotsshp) = ~lng+lat
proj4string(spotsshp) <- CRS("+proj=longlat +datum=WGS84")

writeOGR(spotsshp, dsn = getwd(), layer = "freeganspots", driver = "ESRI Shapefile")

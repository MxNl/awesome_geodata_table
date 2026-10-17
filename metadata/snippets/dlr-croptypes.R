# DLR CropTypes v2: one Cloud-Optimised GeoTIFF per year (2017-2024), read a window directly
library(terra)
year <- 2023
url <- sprintf(
  "https://download.geoservice.dlr.de/CROPTYPES/files/CROPTYPES_DE_P1Y_%d_V02/CROPTYPES_DE_P1Y_%d_V02.tif", year, year
)
crops <- rast(paste0("/vsicurl/", url))  # EPSG:32632, 10 m
aoi <- project(vect(ext(9.9, 10.1, 52.2, 52.3), crs = "EPSG:4326"), crs(crops))
crops_aoi <- crop(crops, aoi)

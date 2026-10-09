# CHIRPS v2.0 monthly precipitation, read directly from the server (no download step)
library(terra)
url <- "https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_monthly/tifs/chirps-v2.0.2020.01.tif.gz"
prec <- rast(paste0("/vsigzip//vsicurl/", url))
prec_aoi <- crop(prec, ext(5, 15, 47, 55))  # lon/lat box

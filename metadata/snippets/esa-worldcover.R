# ESA WorldCover 2021: 3°x3° Cloud-Optimised GeoTIFF tiles on AWS (tile = lower-left corner)
library(terra)
tile <- "N48E009"
lc <- rast(sprintf(
  "/vsicurl/https://esa-worldcover.s3.eu-central-1.amazonaws.com/v200/2021/map/ESA_WorldCover_10m_2021_v200_%s_Map.tif", tile
))
lc_aoi <- crop(lc, ext(9.0, 9.2, 48.7, 48.9))

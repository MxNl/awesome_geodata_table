# Copernicus DEM GLO-30: one 1°x1° Cloud-Optimised GeoTIFF tile from AWS Open Data
# (tile name = lower-left corner, here N50 E010)
library(terra)
tile <- "Copernicus_DSM_COG_10_N50_00_E010_00_DEM"
dem <- rast(sprintf("/vsicurl/https://copernicus-dem-30m.s3.amazonaws.com/%s/%s.tif", tile, tile))

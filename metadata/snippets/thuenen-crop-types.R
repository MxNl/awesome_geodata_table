# Thünen crop type map of Germany (2017-2021): read a window of one year directly from Zenodo
library(terra)
year <- 2021
url <- sprintf("https://zenodo.org/records/10640528/files/CTM_GER_%d_rst_v202_COG.tif", year)
crops <- rast(paste0("/vsicurl/", url))
aoi <- project(vect(ext(9.9, 10.1, 52.2, 52.3), crs = "EPSG:4326"), crs(crops))
crops_aoi <- crop(crops, aoi)
# class legend: CTM_GER_LegendEN_rst_v202.clr in the same Zenodo record

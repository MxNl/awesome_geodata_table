# HydroRIVERS (Europe); other regions: af, ar, as, au, na, sa, si
library(terra)
url <- "https://data.hydrosheds.org/file/HydroRIVERS/HydroRIVERS_v10_eu_shp.zip"
zip <- file.path(tempdir(), basename(url))
download.file(url, zip, mode = "wb")
unzip(zip, exdir = tempdir())
rivers <- vect(list.files(tempdir(), "HydroRIVERS_v10_eu.shp$", recursive = TRUE, full.names = TRUE))

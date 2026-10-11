# HYRAS-DE daily precipitation (1 km, Germany) – one netCDF file per year
library(terra)
url <- "https://opendata.dwd.de/climate_environment/CDC/grids_germany/daily/hyras_de/precipitation/pr_hyras_1_2020_v6-1_de.nc"
file <- file.path(tempdir(), basename(url))
download.file(url, file, mode = "wb")
pr <- rast(file)  # 366 layers (days of 2020), EPSG:3035

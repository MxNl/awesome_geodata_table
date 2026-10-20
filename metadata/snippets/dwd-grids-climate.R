# DWD monthly precipitation grid for Germany (1 km), read directly from the open data server
library(terra)
year <- 2020; month <- 1
url <- sprintf(
  "https://opendata.dwd.de/climate_environment/CDC/grids_germany/monthly/precipitation/%02d_%s/grids_germany_monthly_precipitation_%d%02d.asc.gz",
  month, month.abb[month], year, month
)
prec <- rast(paste0("/vsigzip//vsicurl/", url))
crs(prec) <- "EPSG:31467"  # Gauss-Krüger zone 3, not stored in the ASCII grid
NAflag(prec) <- -999       # mm

# ERA5-Land from the Copernicus Climate Data Store (free account + API key)
library(ecmwfr)
wf_set_key(key = "<your-CDS-API-key>")  # once per machine
request <- list(
  dataset_short_name = "reanalysis-era5-land",
  variable = c("2m_temperature", "total_precipitation"),
  year = "2020", month = sprintf("%02d", 1:12), day = sprintf("%02d", 1:31),
  time = "12:00",
  area = c(55, 5, 47, 15),  # N, W, S, E
  data_format = "netcdf", download_format = "unarchived",
  target = "era5land_2020.nc"
)
file <- wf_request(request, path = tempdir())
r <- terra::rast(file)

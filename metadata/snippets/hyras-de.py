# HYRAS-DE daily precipitation (1 km, Germany) – one netCDF file per year
import urllib.request
import xarray as xr

url = "https://opendata.dwd.de/climate_environment/CDC/grids_germany/daily/hyras_de/precipitation/pr_hyras_1_2020_v6-1_de.nc"
path, _ = urllib.request.urlretrieve(url, "pr_hyras_1_2020_v6-1_de.nc")
pr = xr.open_dataset(path)["pr"]

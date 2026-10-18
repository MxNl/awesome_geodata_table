# DWD monthly precipitation grid for Germany (1 km), read directly from the open data server
import rasterio

year, month = 2020, 1
mon = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][month - 1]
url = (
    "https://opendata.dwd.de/climate_environment/CDC/grids_germany/monthly/precipitation/"
    f"{month:02d}_{mon}/grids_germany_monthly_precipitation_{year}{month:02d}.asc.gz"
)
with rasterio.open(f"/vsigzip//vsicurl/{url}") as src:
    prec = src.read(1, masked=True)  # mm; -999 = missing; CRS is EPSG:31467 (not stored in the file)

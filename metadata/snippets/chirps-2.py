# CHIRPS v2.0 monthly precipitation, read directly from the server
import rasterio
from rasterio.windows import from_bounds

url = "https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_monthly/tifs/chirps-v2.0.2020.01.tif.gz"
with rasterio.open(f"/vsigzip//vsicurl/{url}") as src:
    prec = src.read(1, window=from_bounds(5, 47, 15, 55, src.transform))

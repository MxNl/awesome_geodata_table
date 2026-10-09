# SoilGrids 2.0: read a window of the global VRT directly (Homolosine projection)
import rasterio
from rasterio.warp import transform_bounds
from rasterio.windows import from_bounds

with rasterio.open("/vsicurl/https://files.isric.org/soilgrids/latest/data/clay/clay_0-5cm_mean.vrt") as src:
    bounds = transform_bounds("EPSG:4326", src.crs, 9, 50, 10, 51)
    clay = src.read(1, window=from_bounds(*bounds, src.transform))  # g/kg x 10

# DLR CropTypes v2: list the yearly maps via STAC and read a window of one directly
import rasterio
import requests
from rasterio.warp import transform_bounds
from rasterio.windows import from_bounds

items = requests.get(
    "https://geoservice.dlr.de/eoc/ogc/stac/v1/collections/CROPTYPES_DE_P1Y_V02/items",
    params={"f": "json", "limit": 20},
).json()["features"]
url = next(i["assets"]["data"]["href"] for i in items if i["id"] == "CROPTYPES_DE_P1Y_2023_V02")

with rasterio.open(url) as src:  # EPSG:32632, 10 m
    bounds = transform_bounds("EPSG:4326", src.crs, 9.9, 52.2, 10.1, 52.3)
    crops = src.read(1, window=from_bounds(*bounds, src.transform))

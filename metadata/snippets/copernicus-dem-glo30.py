# Copernicus DEM GLO-30: one 1°x1° Cloud-Optimised GeoTIFF tile from AWS Open Data
import rasterio

tile = "Copernicus_DSM_COG_10_N50_00_E010_00_DEM"
with rasterio.open(f"https://copernicus-dem-30m.s3.amazonaws.com/{tile}/{tile}.tif") as src:
    dem = src.read(1)

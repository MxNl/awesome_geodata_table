# ERA5 single levels from the Copernicus Climate Data Store (free account, key in ~/.cdsapirc)
import cdsapi

cdsapi.Client().retrieve(
    "reanalysis-era5-single-levels",
    {
        "product_type": ["reanalysis"],
        "variable": ["2m_temperature", "total_precipitation"],
        "year": "2020",
        "month": [f"{m:02d}" for m in range(1, 13)],
        "day": [f"{d:02d}" for d in range(1, 32)],
        "time": "12:00",
        "area": [55, 5, 47, 15],  # N, W, S, E
        "data_format": "netcdf",
        "download_format": "unarchived",
    },
    "era5_2020.nc",
)

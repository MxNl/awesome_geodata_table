# GLDAS Noah 0.25° 3-hourly v2.1 via NASA Earthdata (free account; earthaccess asks for it on first login)
import earthaccess

earthaccess.login()
results = earthaccess.search_data(
    short_name="GLDAS_NOAH025_3H",
    version="2.1",
    temporal=("2020-01-01", "2020-01-31"),
    bounding_box=(5, 47, 15, 55),  # W, S, E, N
)
files = earthaccess.download(results, "gldas-noah-2-1")

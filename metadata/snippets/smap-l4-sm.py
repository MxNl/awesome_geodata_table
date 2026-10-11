# SMAP L4 soil moisture (SPL4SMGP v7) via NASA Earthdata (free account; earthaccess asks for it on first login)
import earthaccess

earthaccess.login()
results = earthaccess.search_data(
    short_name="SPL4SMGP",
    version="007",
    temporal=("2020-01-01", "2020-01-31"),
    bounding_box=(5, 47, 15, 55),  # W, S, E, N
)
files = earthaccess.download(results, "smap-l4-sm")

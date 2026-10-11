# JPL GRACE/GRACE-FO mascons RL06.3 v04 via NASA Earthdata (free account; earthaccess asks for it on first login)
import earthaccess

earthaccess.login()
results = earthaccess.search_data(
    short_name="TELLUS_GRAC-GRFO_MASCON_GRID_RL06.3_V4",
    temporal=("2020-01-01", "2020-01-31"),
    bounding_box=(5, 47, 15, 55),  # W, S, E, N
)
files = earthaccess.download(results, "grace-mascon-jpl")

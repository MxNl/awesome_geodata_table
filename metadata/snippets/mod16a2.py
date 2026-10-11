# MOD16A2 v061 8-day evapotranspiration via NASA Earthdata (free account; earthaccess asks for it on first login)
import earthaccess

earthaccess.login()
results = earthaccess.search_data(
    short_name="MOD16A2",
    version="061",
    temporal=("2020-01-01", "2020-01-31"),
    bounding_box=(5, 47, 15, 55),  # W, S, E, N
)
files = earthaccess.download(results, "mod16a2")

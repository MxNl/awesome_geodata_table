# One-off (2026-10): add the round-2 columns to the existing metadata
#   parameters.csv: variable        (standard variable, rule based + manual fixes)
#   datasets.csv:   license_class, bbox_*, last_verified
#
# Run from the project root: Rscript data-raw/assign_variables.R

library(dplyr)
library(readr)
library(stringr)
library(purrr)

ds_path <- "metadata/datasets.csv"
pa_path <- "metadata/parameters.csv"
ds <- read_csv(ds_path, col_types = cols(.default = "c"), na = "")
pa <- read_csv(pa_path, col_types = cols(.default = "c"), na = "")
stopifnot(!"variable" %in% names(pa), !"license_class" %in% names(ds))

# Variables: first matching rule wins (case-insensitive) ---------------------------
rules <- tribble(
  ~pattern, ~variable,
  "data quality index|data certainty index|skin reservoir|lake shape", "other",
  "^(hydroatlas)$", "catchment_attributes",
  "^precipitation, temperature, river discharge$", "catchment_attributes",
  "streamflow indices", "river_discharge",
  "groundwater recharge|^artificial recharge$", "groundwater_recharge",
  "groundwater depletion|groundwater withdraw|groundwater stress", "groundwater_use",
  "groundwater quality|arsenic|fluoride|saline and brackish|seawater intrusion", "groundwater_quality",
  "monitoring network|groundwater data per country", "groundwater_monitoring",
  "terrestrial water storage", "water_storage",
  "aquifer|groundwater bodies|groundwater resources type|consolidation|transboundary", "aquifer_units",
  "permeability|porosity", "aquifer_properties",
  "thickness", "subsurface_thickness",
  "lithology|stratigraph|petrograph|petrogenesis|geochemical rock|tectonic fractures", "lithology",
  "stream distance|lateral position", "hydrologic_position",
  "potential evapo|reference evapo|potential evaporation", "potential_evapotranspiration",
  "evapo|evaporation|latent heat|transpiration", "evapotranspiration",
  "soil moisture|soil water|volumetric soil", "soil_moisture",
  "soil temperature", "soil_temperature",
  "clay|sand content|silt|coarse fragments", "soil_texture",
  "bulk density|field capacity", "soil_physics",
  "organic carbon|soil ph|nitrogen|cation exchange", "soil_chemistry",
  "soil type|soil mapping units", "soil_type",
  "snow", "snow",
  "precipitation|snowfall|\\brain", "precipitation",
  "runoff|run-off", "runoff",
  "discharge", "river_discharge",
  "lake|water bodies|water occurrence|occurrence change|recurrence|seasonality|transitions|maximum water extent|monthly water history|reservoir|residence time", "surface_water",
  "dewpoint|humidity|vapour pressure", "humidity",
  "temperature", "air_temperature",
  "radiation|albedo|heat flux|cloud", "radiation",
  "wind", "wind",
  "orography", "elevation",
  "pressure|geopotential", "air_pressure",
  "aridity|drought|bioclimatic|climatic water deficit", "climate_index",
  "flow direction|flow accumulation|flow length|upstream|river network|river channel|stream order|height above nearest drainage", "drainage_network",
  "elevation", "elevation",
  "slope|aspect|curvature|roughness|rugged|landform|eastness|northness|topographic position|partial derivative|count of geomorphological", "terrain_derivatives",
  "ndvi|^evi$|leaf area|vegetation", "vegetation",
  "imperviousness|artificial surfaces", "imperviousness",
  "irrigat", "irrigation",
  "population", "population",
  "pesticide|active ingredient|regions of concern", "pollution",
  "land cover|land mask|land-sea mask|land area fraction|fraction of|cropland|grassland|shrubs|mangroves|baresoil|tree covered", "land_cover",
)

assign_variable <- function(parameter) {
  p <- str_to_lower(parameter)
  hit <- detect_index(rules$pattern, \(rx) str_detect(p, rx))
  if (hit == 0) NA_character_ else rules$variable[hit]
}

pa <- pa |>
  mutate(variable = map_chr(parameter, assign_variable), .after = unit) |>
  mutate(variable = case_when(
    # exact fixes where the generic rules mislead
    dataset_id == "jrc-lai-europe" ~ "vegetation",
    dataset_id == "glc-share" & str_detect(parameter, "water") ~ "surface_water",
    dataset_id == "glc-share" & str_detect(parameter, "snow") ~ "land_cover",
    str_detect(str_to_lower(parameter), "^lake (bottom|ice|mix|total)") ~ "surface_water",
    str_detect(str_to_lower(parameter), "skin temperature") ~ "radiation",
    .default = variable
  ))

unassigned <- filter(pa, is.na(variable))
if (nrow(unassigned) > 0) {
  print(unassigned |> select(dataset_id, parameter), n = 100)
  stop("unassigned parameters")
}

# License classes -------------------------------------------------------------------
license_class_of <- function(license, id) {
  l <- str_to_lower(coalesce(license, ""))
  case_when(
    # stated in the dataset comments: non-commercial use only
    id %in% c("ufz-duerremonitor", "glwd-1") ~ "non-commercial",
    str_detect(l, "non-commercial|by-nc") & !str_detect(l, "odbl") ~ "non-commercial",
    str_detect(l, "^cc|public domain|copernicus|hydrosheds|eosdis|geonutzv|odbl") ~ "open",
    str_detect(l, "policy|terms") ~ "custom terms",
    .default = "unknown"
  )
}

ds <- ds |>
  mutate(license_class = license_class_of(license, id), .after = license) |>
  mutate(bbox_west = NA_character_, bbox_south = NA_character_, bbox_east = NA_character_, bbox_north = NA_character_)

# datasets whose extent differs from their region (from the provider pages)
bbox_overrides <- tribble(
  ~id, ~bbox_west, ~bbox_south, ~bbox_east, ~bbox_north,
  "chirps-2", "-180", "-50", "180", "50",
  "pelletier-regolith", "-180", "-60", "180", "90"
)
ds <- rows_update(ds, bbox_overrides, by = "id")

# entries checked against the provider pages on 2026-10-08 (round 1 additions)
verified <- c(
  "glhymps-2", "glim", "pelletier-regolith", "whymap-gwr", "hydrosheds", "hydrorivers",
  "hydrolakes", "merit-hydro", "jrc-global-surface-water", "grace-mascon-jpl",
  "copernicus-dem-glo30", "era5", "chirps-2", "worldclim-2", "terraclimate",
  "global-aridity-pet-3", "gldas-noah-2-1", "mod16a2", "mod13q1", "esa-cci-soil-moisture",
  "esa-worldcover", "ghs-pop", "e-obs", "ihme1500", "hyras-de", "huek250", "guek250",
  "buek250", "gwn1000"
)
ds <- ds |> mutate(last_verified = if_else(id %in% verified, "2026-10-08", NA_character_))

write_csv(ds, ds_path, na = "")
write_csv(pa, pa_path, na = "")
message("variables: ", paste(names(table(pa$variable)), table(pa$variable), sep = "=", collapse = ", "))
message("license classes: ", paste(names(table(ds$license_class)), table(ds$license_class), sep = "=", collapse = ", "))

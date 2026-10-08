# One-off migration of the legacy Google-Sheet export
# (legacy/extdata/awesome_geodata_table.csv, one row per parameter, 33 columns)
# The legacy/ folder has since been deleted; restore the input from git history with
#   mkdir -p legacy/extdata && git show 75b72df:legacy/extdata/awesome_geodata_table.csv > legacy/extdata/awesome_geodata_table.csv
# into metadata/datasets.csv + metadata/parameters.csv.
#
# Run from the project root: Rscript data-raw/migrate_v1.R --force
#
# Already applied (2026-10). metadata/*.csv has been edited since, so running
# this again would overwrite those edits; it is kept to document the migration.

if (!"--force" %in% commandArgs(trailingOnly = TRUE) && file.exists("metadata/datasets.csv")) {
  stop("metadata/datasets.csv exists; rerunning the migration would overwrite it. Use --force.", call. = FALSE)
}

library(dplyr)
library(readr)
library(stringr)
library(purrr)

legacy <- read_delim(
  "legacy/extdata/awesome_geodata_table.csv",
  delim = ";", col_names = FALSE, col_types = cols(.default = "c"),
  locale = locale(encoding = "latin1"), na = c("", "NA")
)
names(legacy) <- make.unique(unlist(legacy[3, ]))
legacy <- legacy[-(1:3), ] |>
  mutate(across(everything(), str_squish)) |>
  distinct()

# Per-dataset decisions that cannot be derived from the legacy table -----------
dataset_map <- tribble(
  ~old_name, ~id, ~name, ~domain, ~coverage_spatial,
  "CORDEX", "cordex", "Coordinated Regional Climate Downscaling Experiment (CORDEX)", "Climate & atmosphere", "Global",
  "CORINE Land Cover", "corine-land-cover", "CORINE Land Cover (CLC)", "Land cover & land use", "Europe",
  "Caravan", "caravan", "Caravan – large-sample hydrology dataset", "Hydrology", "Global",
  "Dürremonitor Deutschland", "ufz-duerremonitor", "Dürremonitor Deutschland (UFZ drought monitor)", "Hydrology", "Germany",
  "ERA5-Land HRES", "era5-land", "ERA5-Land hourly reanalysis", "Climate & atmosphere", "Global",
  "Global 1,5,10,100-km Topography", "earthenv-topography", "EarthEnv Global 1, 5, 10, 100-km Topography", "Topography", "Global",
  "Global Groundwater Information System (GGIS)", "igrac-ggis", "Global Groundwater Information System (GGIS)", "Hydrogeology", "Global",
  "Global Lakes and Wetlands Database - Large Lake Polygons (level 1)", "glwd-1", "Global Lakes and Wetlands Database – Large Lake Polygons (GLWD level 1)", "Hydrology", "Global",
  "Global Land Cover-SHARE (GLC-SHARE)", "glc-share", "Global Land Cover-SHARE (GLC-SHARE)", "Land cover & land use", "Global",
  "Global Map of Irrigation Areas v5.0 (GMIA)", "gmia", "Global Map of Irrigation Areas v5.0 (GMIA)", "Agriculture & water use", "Global",
  "Global Runoff Data Base", "grdc", "Global Runoff Database (GRDC)", "Hydrology", "Global",
  "Global Streamflow Indices and Metadata Archive (GSIM)", "gsim", "Global Streamflow Indices and Metadata Archive (GSIM)", "Hydrology", "Global",
  "Global pesticide pollution risk", "pesticide-risk", "Global pesticide pollution risk", "Water quality & pollution", "Global",
  "HydroATLAS", "hydroatlas", "HydroATLAS", "Hydrology", "Global",
  "Imperviousness", "clms-imperviousness", "Copernicus HRL Imperviousness", "Land cover & land use", "Europe",
  "LAI", "jrc-lai-europe", "Leaf Area Index Europe (JRC)", "Vegetation & ecology", "Europe",
  "Multiorder Hydrologic Position for Europe (EU-MOHP)", "eu-mohp", "Multiorder Hydrologic Position for Europe (EU-MOHP)", "Hydrogeology", "Europe",
  "Open Street Map", "openstreetmap", "OpenStreetMap (OSM)", "Land cover & land use", "Global",
  "SoilGrids 2.0", "soilgrids", "SoilGrids 2.0", "Soil", "Global"
)
stopifnot(setequal(dataset_map$old_name, legacy$`Dataset name`))

# Value translations ------------------------------------------------------------
temporal_res_map <- c(
  "<=1h" = "hourly", ">1h - <=1d" = "daily", ">1d - <=7d" = "weekly",
  ">7d - <=1m" = "monthly", ">1m - <=1a" = "yearly", ">1a - <=10a" = "decadal",
  "static" = "static"
)

unit_map <- c(
  "-" = "-", "(0-1)" = "0–1", "%" = "%", "10pH" = "pH × 10",
  "categorical" = "categorical", "ordinal" = "ordinal", "K" = "K", "m" = "m",
  "Pa" = "Pa", "unknown" = NA,
  "\\frac{cg}{cm^3}" = "cg/cm³", "\\frac{cg}{kg}" = "cg/kg",
  "\\frac{cm^3}{dm^3}" = "cm³/dm³", "\\frac{dg}{kg}" = "dg/kg",
  "\\frac{g}{kg}" = "g/kg", "\\frac{hg}{m^3}" = "hg/m³", "\\frac{J}{m^2}" = "J/m²",
  "\\frac{kg}{m^2s}" = "kg/(m²·s)", "\\frac{kg}{m^3}" = "kg/m³", "\\frac{m}{s}" = "m/s",
  "\\frac{m^2}{m^2}" = "m²/m²", "\\frac{m^2}{s^2}" = "m²/s²",
  "\\frac{m^3}{m^3}" = "m³/m³", "\\frac{mm}{a}" = "mm/a",
  "\\frac{mmol}{kg}" = "mmol/kg", "\\frac{rad}{m}" = "rad/m", "\\frac{t}{ha}" = "t/ha",
  "\\frac{W}{s^2}" = "W/s²", "m_{water\\_equivalent}" = "m water equivalent"
)
stopifnot(all(na.omit(unique(legacy$Unit)) %in% names(unit_map)))

access_map <- c(
  "free (API)" = "open", "free (account)" = "registration",
  "free (file download)" = "open", "free (contact sheet)" = "on request"
)
access_method_map <- c(
  "free (API)" = "API", "free (account)" = "download",
  "free (file download)" = "download", "free (contact sheet)" = "request form"
)

license_map <- c(
  "Copernicus C3S/CAMS" = "Copernicus licence", "CCBY" = "CC BY",
  "CC BY 4.0" = "CC BY 4.0", "IGRAC" = "IGRAC terms of use",
  "Custom data policy" = "GRDC data policy", "unknown" = NA
)

tidy_tags <- function(x) {
  x |>
    str_to_lower() |>
    str_replace_all(c("infraestructure" = "infrastructure", "run-off" = "runoff")) |>
    str_split(",\\s*") |>
    map_chr(\(t) {
      t <- unique(str_squish(t[!is.na(t) & t != "" & t != "na"]))
      if (length(t) == 0) NA_character_ else str_c(t, collapse = "; ")
    })
}

year_of <- function(x) str_sub(x, 1, 4)

# Translate every legacy row to the new field names -----------------------------
rows <- legacy |>
  left_join(dataset_map, by = c("Dataset name" = "old_name")) |>
  transmute(
    id, name, domain, coverage_spatial,
    parameter = str_squish(Parameter),
    unit = unname(unit_map[Unit]),
    tags = tidy_tags(Tags),
    publisher = Publisher,
    data_type = if_else(id == "grdc", "point", type),
    format = str_replace_all(format, ",\\s*", "; ") |>
      str_replace_all(c("GeoTiff" = "GeoTIFF", "^Shape$" = "Shapefile", "shapefile" = "Shapefile", "Shape;" = "Shapefile;")),
    crs = `Coordinate reference system`,
    res_spatial_finest_m = `min [m]`,
    res_spatial_coarsest_m = `max [m]`,
    res_spatial_note = if_else(`unconverted units` %in% c(`min [m]`, `max [m]`), NA, `unconverted units`),
    res_temporal_finest = unname(temporal_res_map[min]),
    res_temporal_coarsest = unname(temporal_res_map[max]),
    coverage_start = year_of(start),
    coverage_end = year_of(end),
    temporal_type = `Temporal type`,
    vertical = case_when(
      vertical == "above surface" & domain == "Climate & atmosphere" ~ "atmosphere",
      vertical == "above surface" ~ "land surface",
      id == "clms-imperviousness" ~ "land surface",
      vertical == "all" ~ "multiple",
      vertical == "0.25m, 1.8m" ~ "shallow subsurface",
      .default = vertical
    ),
    maintained = `Version updates`,
    latency = recode(`Upload delay`,
      "-" = NA_character_, "unknown" = NA_character_, "1d" = "1 day",
      "3m" = "3 months", "3a" = "3 years", "6a" = "6 years"
    ),
    published = `Published first`,
    method = Method,
    processing_level = recode(`Usage requirement`,
      "preprocessing" = "preprocessing needed",
      "simple transformation of raster values required" = "preprocessing needed"
    ),
    access = unname(access_map[Access]),
    access_method = unname(access_method_map[Access]),
    license = if_else(License %in% names(license_map), unname(license_map[License]), License),
    download_url = Download,
    doc_url = Literature,
    quality_notes = if_else(`Data limitations` %in% c("undefined", "unknown", "reliable"), NA, `Data limitations`),
    comment = Comment
  ) |>
  mutate(
    # ongoing time series: start given, no end, still updated
    coverage_end = if_else(
      !is.na(coverage_start) & is.na(coverage_end) & temporal_type %in% c("dynamic", "semi-static"),
      "present", coverage_end
    ),
    across(everything(), \(v) if_else(v %in% c("-", ""), NA, v))
  )

# Split into dataset level and parameter overrides ------------------------------
variable_fields <- c(
  "tags", "res_temporal_finest", "res_temporal_coarsest", "vertical",
  "coverage_start", "coverage_end", "coverage_spatial", "temporal_type",
  "latency", "comment"
)
dataset_fields <- setdiff(names(rows), c("parameter", "unit"))

most_frequent <- function(v) {
  tab <- table(v, useNA = "ifany")
  names(tab)[which.max(tab)]
}

datasets <- rows |>
  group_by(id) |>
  summarise(
    # legacy sheet contains drag-filled series (ERA5, ERA6, …) → keep the first value
    across(all_of(setdiff(dataset_fields, c("id", variable_fields))), first),
    across(all_of(variable_fields), most_frequent)
  ) |>
  select(all_of(dataset_fields)) |>
  arrange(name)


parameters <- rows |>
  left_join(datasets, by = "id", suffix = c("", ".ds")) |>
  mutate(across(all_of(variable_fields), \(v) {
    ds <- get(str_c(cur_column(), ".ds"))
    case_when(
      cur_column() == "tags" ~ map2_chr(v, ds, \(p, d) {
        extra <- setdiff(str_split_1(coalesce(p, ""), "; "), c(str_split_1(coalesce(d, ""), "; "), ""))
        if (length(extra) == 0) NA_character_ else str_c(extra, collapse = "; ")
      }),
      is.na(v) & !is.na(ds) ~ "none",
      !is.na(v) & v == coalesce(ds, "") ~ NA,
      .default = v
    )
  })) |>
  select(dataset_id = id, parameter, unit, all_of(variable_fields)) |>
  distinct(dataset_id, parameter, .keep_all = TRUE) |>
  arrange(dataset_id, parameter)

# drop override columns that are never used
parameters <- parameters |>
  select(dataset_id, parameter, unit, where(\(v) any(!is.na(v))))

# Gaps in the legacy sheet, filled from the dataset landing pages / publications
patches <- tribble(
  ~id, ~field, ~value,
  "hydroatlas", "publisher", "WWF; McGill University",
  "hydroatlas", "tags", "catchment; river network; hydro-environmental attributes; hydrosheds",
  "hydroatlas", "data_type", "vector",
  "hydroatlas", "format", "Shapefile; ESRI Geodatabase",
  "hydroatlas", "crs", "EPSG:4326",
  "hydroatlas", "res_spatial_note", "15 arc-sec (HydroSHEDS)",
  "hydroatlas", "res_temporal_finest", "static",
  "hydroatlas", "res_temporal_coarsest", "static",
  "hydroatlas", "temporal_type", "static",
  "hydroatlas", "vertical", "multiple",
  "hydroatlas", "published", "2019",
  "hydroatlas", "method", "hybrid",
  "hydroatlas", "processing_level", "final product",
  "hydroatlas", "access", "open",
  "hydroatlas", "access_method", "download",
  "hydroatlas", "license", "CC BY 4.0",
  "hydroatlas", "doi", "10.1038/s41597-019-0300-6",
  "gsim", "publisher", "PANGAEA",
  "gsim", "tags", "streamflow; discharge; river; streamflow indices",
  "gsim", "data_type", "point",
  "gsim", "format", "ASCII text",
  "gsim", "res_temporal_finest", "monthly",
  "gsim", "res_temporal_coarsest", "yearly",
  "gsim", "temporal_type", "aggregated-dynamic",
  "gsim", "vertical", "land surface",
  "gsim", "method", "observation-based",
  "gsim", "processing_level", "final product",
  "gsim", "license", "CC BY 4.0",
  "gsim", "doi", "10.5194/essd-10-765-2018",
  "era5-land", "doi", "10.5194/essd-13-4349-2021",
  "soilgrids", "doi", "10.5194/soil-7-217-2021",
  "earthenv-topography", "doi", "10.1038/sdata.2018.40",
  "caravan", "doi", "10.1038/s41597-023-01975-w",
  "pesticide-risk", "doi", "10.1038/s41561-021-00712-5",
  "eu-mohp", "doi", "10.4211/hs.0d6999591fb048cab5ab71fcb690eadb"
)
datasets$doi <- NA_character_
for (i in seq_len(nrow(patches))) {
  datasets[[patches$field[i]]][datasets$id == patches$id[i]] <- patches$value[i]
}
datasets <- relocate(datasets, doi, .after = doc_url)

write_csv(datasets, "metadata/datasets.csv", na = "")
write_csv(parameters, "metadata/parameters.csv", na = "")
message(nrow(datasets), " datasets, ", nrow(parameters), " parameters written.")

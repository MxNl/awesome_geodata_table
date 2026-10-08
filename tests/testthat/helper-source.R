# The project is not an installed package: source the build functions directly.
project_root <- normalizePath(test_path("..", ".."))
for (f in list.files(file.path(project_root, "R"), pattern = "\\.R$", full.names = TRUE)) {
  source(f, local = FALSE)
}
metadata_dir <- file.path(project_root, "metadata")

# minimal valid metadata, modified by individual tests
fixture_datasets <- function() {
  tibble::tibble(
    id = c("ds-a", "ds-b"),
    name = c("Dataset A", "Dataset B"),
    domain = c("Soil", "Hydrology"),
    coverage_spatial = c("Global", "Europe"),
    tags = c("soil; texture", "river"),
    res_spatial_finest_m = c("250", "1000"),
    res_spatial_coarsest_m = c("250", "5000"),
    res_temporal_finest = c("static", "daily"),
    res_temporal_coarsest = c("static", "monthly"),
    coverage_start = c(NA, "1990"),
    coverage_end = c(NA, "present"),
    access = c("open", "registration"),
    download_url = c("https://example.org/a", "https://example.org/b")
  )
}

fixture_parameters <- function() {
  tibble::tibble(
    dataset_id = c("ds-a", "ds-a", "ds-b"),
    parameter = c("clay content", "sand content", "discharge"),
    unit = c("g/kg", "g/kg", "m³/s"),
    tags = c(NA, "sand", NA),
    coverage_end = c(NA, NA, "2020")
  )
}

generate_entry_description <- function() {
  headers_as_in_csv <- complex_header() |>
    unique_headers_clean()

  headers_defined <- list(
    `Name` = list(
      short_description = "Full name of the dataset with optional abbreviation in round brackets",
      details = "teeeeeeext"
    ),
    `Covered_Variables` = list(
      short_description = "Name of a single parameter/variable in the dataset",
      details = "teeeeeeext"
    ),
    `Tags` = list(
      short_description = "Tags related to the dataset",
      details = "teeeeeeext"
    ),
    `Domain` = list(
      short_description = "Strongest associated domain",
      details = "teeeeeeext"
    ),
    `Resolution-temporal-min` = list(
      short_description = "Minimum temporal resolution",
      details = "teeeeeeext"
    ),
    `Resolution-temporal-max` = list(
      short_description = "Maximum temporal resolution",
      details = "teeeeeeext"
    ),
    `Resolution-spatial-min_[m]` = list(
      short_description = "Minimum spatial resolution in meters",
      details = "teeeeeeext"
    ),
    `Resolution-spatial-max_[m]` = list(
      short_description = "Maximum spatial resolution in meters",
      details = "teeeeeeext"
    ),
    `Resolution-spatial-unconverted_units` = list(
      short_description = "Raw units of the spatial resolution",
      details = "teeeeeeext"
    ),
    `Resolution-spatial-vertical` = list(
      short_description = "Vertical spatial resolution",
      details = "teeeeeeext"
    ),
    `Extent-temporal-start` = list(
      short_description = "Start of the covered period",
      details = "teeeeeeext"
    ),
    `Extent-temporal-end` = list(
      short_description = "End of the covered period",
      details = "teeeeeeext"
    ),
    `Extent-spatial` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Data-type` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Data-format` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Data-file_extension` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Download_link` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Literatur-year_(first)` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Literatur-link` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Version_updates` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Upload_frequency` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Temporal_type` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Access` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Publisher` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Data_limitations` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Method` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Usage_requirement` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `minTempRes` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `maxTempRes` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Comment` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    )
  ) |>
    tibble::enframe() |>
    tidyr::unnest_wider(value)

  headers_as_in_csv |>
    inner_join(headers_defined, by = c("column_names" = "name")) |>
    mutate(merged = stringr::str_glue("{column_names}: <{short_description} (data type: {details})>")) |>
    pull(merged) |>
    stringr::str_c(collapse = "\n") |>
    cat()

  # complex_header() |>
  #   unique_headers_clean() |>
  #   mutate(column_names = stringr::str_glue("`{column_names}`")) |>
  #   mutate(add_string = " = list(\nshort_description = 'teeeeext',\n details = 'teeeeeeext'),\n") |>
  #   mutate(merged = stringr::str_c(column_names, add_string)) |>
  #   pull(merged) |>
  #   stringr::str_c(collapse = " ") |>
  #   cat()

}

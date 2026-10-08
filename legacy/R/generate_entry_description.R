generate_entry_description <- function(filepath) {
  headers_as_in_csv <- complex_header(filepath) |>
    unique_headers_clean()

  headers_defined <- list(
    Parameter = list(
      short_description = "Name of a single parameter/variable in the dataset",
      details = "teeeeeeext"
    ),
    `Dataset_name` = list(
      short_description = "Full name of the dataset with optional abbreviation in round brackets",
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
    Unit = list(
      short_description = "Unit or dimension of the parameter",
      details = "teeeeeeext"
    ),
    `Resolution_(temporal)-min` = list(
      short_description = "Minimum temporal resolution",
      details = "teeeeeeext"
    ),
    `Resolution_(temporal)-max` = list(
      short_description = "Maximum temporal resolution",
      details = "teeeeeeext"
    ),
    `Resolution_(spatial)-min_[m]` = list(
      short_description = "Minimum spatial resolution in meters",
      details = "teeeeeeext"
    ),
    `Resolution_(spatial)-max_[m]` = list(
      short_description = "Maximum spatial resolution in meters",
      details = "teeeeeeext"
    ),
    `Resolution_(spatial)-unconverted_units` = list(
      short_description = "Raw units of the spatial resolution",
      details = "teeeeeeext"
    ),
    `Resolution_(spatial)-vertical` = list(
      short_description = "Vertical spatial resolution",
      details = "teeeeeeext"
    ),
    `Coverage_(temporal)-start` = list(
      short_description = "Start of the covered period",
      details = "teeeeeeext"
    ),
    `Coverage_(temporal)-end` = list(
      short_description = "End of the covered period",
      details = "teeeeeeext"
    ),
    `Coverage_(spatial)` = list(
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
    Coordinate_reference_system = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Download` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    Published_first = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    Literature = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    `Version_updates` = list(
      short_description = "teeeeext",
      details = "teeeeeeext"
    ),
    Upload_delay = list(
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
    `License` = list(
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
    tidyr::unnest_wider(value) %>%
    assertr::verify(identical(.$name, headers_as_in_csv$column_names))

  headers_as_in_csv |>
    dplyr::inner_join(headers_defined, by = c("column_names" = "name")) |>
    dplyr::mutate(merged = stringr::str_glue("{column_names}: <{short_description} (data type: {details})>")) |>
    dplyr::pull(merged) |>
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

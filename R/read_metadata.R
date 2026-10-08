#' Read the metadata schema
#'
#' @param dir Directory containing `schema.yaml`.
#' @return The parsed schema as a list.
read_schema <- function(dir = "metadata") {
  yaml::read_yaml(file.path(dir, "schema.yaml"))
}

#' Read a metadata CSV with every column as character
read_metadata_csv <- function(path) {
  readr::read_csv(
    path,
    col_types = readr::cols(.default = readr::col_character()),
    na = c("", "NA"),
    trim_ws = TRUE,
    progress = FALSE
  )
}

#' Keys of a vocabulary (vocabularies are plain strings or key/label pairs)
vocab_keys <- function(schema, vocab) {
  purrr::map_chr(schema$vocabularies[[vocab]], \(v) if (is.list(v)) v$key else v)
}

#' Labels of a vocabulary, named by key
vocab_labels <- function(schema, vocab) {
  v <- schema$vocabularies[[vocab]]
  purrr::set_names(
    purrr::map_chr(v, \(x) if (is.list(x)) x$label else x),
    vocab_keys(schema, vocab)
  )
}

#' Split a `;`-separated tag string into a character vector
split_tags <- function(x) {
  if (is.na(x) || x == "") {
    return(character())
  }
  stringr::str_squish(stringr::str_split_1(x, ";")) |>
    purrr::discard(\(t) t == "")
}

#' Combine dataset and parameter tags without duplicates
merge_tags <- function(dataset_tags, parameter_tags) {
  purrr::map2_chr(dataset_tags, parameter_tags, \(d, p) {
    tags <- unique(c(split_tags(d), split_tags(p)))
    if (length(tags) == 0) NA_character_ else stringr::str_c(tags, collapse = "; ")
  })
}

#' Join parameters with their dataset, applying parameter-level overrides
#'
#' Columns of `parameters` that also exist in `datasets` override the dataset
#' value when filled; the literal `none` overrides with `NA`. Tags are merged.
merge_metadata <- function(datasets, parameters) {
  overrides <- intersect(setdiff(names(parameters), c("dataset_id", "parameter")), names(datasets))

  merged <- parameters |>
    dplyr::rename(id = dataset_id) |>
    dplyr::left_join(datasets, by = "id", suffix = c(".param", ""))

  for (field in overrides) {
    param_value <- merged[[paste0(field, ".param")]]
    merged[[field]] <- if (field == "tags") {
      merge_tags(merged[[field]], param_value)
    } else {
      dplyr::case_when(
        param_value == "none" ~ NA_character_,
        !is.na(param_value) ~ param_value,
        .default = merged[[field]]
      )
    }
  }

  merged |>
    dplyr::select(-dplyr::ends_with(".param")) |>
    dplyr::relocate(id, name, parameter, unit)
}

#' Read, validate and merge the metadata into one row per parameter
#'
#' @param dir Directory containing `datasets.csv`, `parameters.csv` and `schema.yaml`.
#' @param validate Stop with an informative error when the metadata is invalid.
#' @return A tibble with one row per parameter and typed helper columns used by
#'   the table filters (`*_rank`, `coverage_*_year`).
read_metadata <- function(dir = "metadata", validate = TRUE) {
  schema <- read_schema(dir)
  datasets <- read_metadata_csv(file.path(dir, "datasets.csv"))
  parameters <- read_metadata_csv(file.path(dir, "parameters.csv"))

  if (validate) {
    assert_valid_metadata(datasets, parameters, schema)
  }

  temporal_levels <- vocab_keys(schema, "temporal_resolution")
  current_year <- as.integer(format(Sys.Date(), "%Y"))

  merge_metadata(datasets, parameters) |>
    dplyr::mutate(
      dplyr::across(c(res_spatial_finest_m, res_spatial_coarsest_m), as.numeric),
      res_temporal_finest_rank = match(res_temporal_finest, temporal_levels),
      res_temporal_coarsest_rank = match(res_temporal_coarsest, temporal_levels),
      coverage_start_year = as.integer(coverage_start),
      coverage_end_year = dplyr::if_else(
        coverage_end == "present", current_year, suppressWarnings(as.integer(coverage_end))
      )
    ) |>
    dplyr::arrange(name, parameter)
}

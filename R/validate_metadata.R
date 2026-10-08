#' Validate the metadata against the schema
#'
#' @param datasets,parameters Raw tibbles as read by `read_metadata_csv()`.
#' @param schema Schema as returned by `read_schema()`.
#' @return A tibble of problems (`file`, `row`, `field`, `value`, `problem`);
#'   zero rows when everything is valid. `row` is the line number in the CSV.
validate_metadata <- function(datasets, parameters, schema) {
  problems <- list()
  add <- function(file, row, field, value, problem) {
    if (length(row) > 0) {
      problems[[length(problems) + 1]] <<- tibble::tibble(
        file = file, row = as.integer(row) + 1L, field = field,
        value = as.character(value), problem = problem
      )
    }
  }

  check_columns <- function(data, file, spec, optional_spec = list()) {
    unknown <- setdiff(names(data), c(names(spec), names(optional_spec)))
    for (col in unknown) add(file, 0, col, NA, "unknown column")
    missing <- setdiff(names(purrr::keep(spec, \(f) isTRUE(f$required))), names(data))
    for (col in missing) add(file, 0, col, NA, "required column missing")
  }

  check_values <- function(data, file, spec, allow_none = FALSE) {
    for (field in intersect(names(spec), names(data))) {
      f <- spec[[field]]
      v <- data[[field]]
      if (allow_none) v[v %in% "none"] <- NA
      filled <- !is.na(v)

      if (isTRUE(f$required) && !allow_none) {
        idx <- which(!filled)
        add(file, idx, field, v[idx], "required value missing")
      }

      bad <- switch(f$type,
        vocab = filled & !v %in% vocab_keys(schema, f$vocab),
        number = filled & (is.na(suppressWarnings(as.numeric(v))) | suppressWarnings(as.numeric(v)) <= 0),
        year = filled & !stringr::str_detect(v, if (field == "coverage_end") "^(\\d{4}|present)$" else "^\\d{4}$"),
        url = filled & !stringr::str_detect(v, "^https?://\\S+$"),
        tags = filled & (stringr::str_detect(v, ",") | v != stringr::str_to_lower(v)),
        rep(FALSE, length(v))
      )
      message <- switch(f$type,
        vocab = paste0("not in vocabulary '", f$vocab, "'"),
        number = "must be a positive number",
        year = "must be a 4-digit year",
        url = "must be an http(s) URL",
        tags = "tags must be lower case and separated by ';'",
        ""
      )
      idx <- which(bad)
      add(file, idx, field, v[idx], message)
    }
  }

  dataset_spec <- schema$datasets
  # parameters may override any dataset field except the id
  override_spec <- dataset_spec[setdiff(names(dataset_spec), "id")]

  check_columns(datasets, "datasets.csv", dataset_spec)
  check_columns(parameters, "parameters.csv", schema$parameters, override_spec)
  check_values(datasets, "datasets.csv", dataset_spec)
  check_values(parameters, "parameters.csv", schema$parameters)
  check_values(
    parameters[setdiff(names(parameters), names(schema$parameters))],
    "parameters.csv", dataset_spec, allow_none = TRUE
  )

  # identity and references
  idx <- which(duplicated(datasets$id))
  add("datasets.csv", idx, "id", datasets$id[idx], "duplicated id")
  idx <- which(!is.na(datasets$id) & !stringr::str_detect(datasets$id, "^[a-z0-9]+(-[a-z0-9]+)*$"))
  add("datasets.csv", idx, "id", datasets$id[idx], "id must be a lower-case slug (a-z, 0-9, -)")
  idx <- which(!parameters$dataset_id %in% datasets$id)
  add("parameters.csv", idx, "dataset_id", parameters$dataset_id[idx], "unknown dataset id")
  idx <- which(duplicated(parameters[c("dataset_id", "parameter")]))
  add("parameters.csv", idx, "parameter", parameters$parameter[idx], "duplicated parameter within dataset")
  idx <- which(!datasets$id %in% parameters$dataset_id)
  add("datasets.csv", idx, "id", datasets$id[idx], "dataset has no parameters")

  # consistency of ranges (checked after inheritance)
  if (all(c("id", "dataset_id") %in% c(names(datasets), names(parameters)))) {
    # duplicated ids are reported above; keep the first to avoid a many-to-many join
    merged <- merge_metadata(datasets[!duplicated(datasets$id), ], parameters)
    row_of <- match(paste(merged$id, merged$parameter), paste(parameters$dataset_id, parameters$parameter))

    finest <- suppressWarnings(as.numeric(merged$res_spatial_finest_m))
    coarsest <- suppressWarnings(as.numeric(merged$res_spatial_coarsest_m))
    idx <- which(finest > coarsest)
    add("parameters.csv", row_of[idx], "res_spatial_finest_m", finest[idx], "finest spatial resolution is coarser than the coarsest")

    levels <- vocab_keys(schema, "temporal_resolution")
    idx <- which(match(merged$res_temporal_finest, levels) > match(merged$res_temporal_coarsest, levels))
    add("parameters.csv", row_of[idx], "res_temporal_finest", merged$res_temporal_finest[idx], "finest temporal resolution is coarser than the coarsest")

    start <- suppressWarnings(as.integer(merged$coverage_start))
    end <- dplyr::if_else(merged$coverage_end %in% "present", 9999L, suppressWarnings(as.integer(merged$coverage_end)))
    idx <- which(start > end)
    add("parameters.csv", row_of[idx], "coverage_start", start[idx], "coverage starts after it ends")
  }

  dplyr::bind_rows(
    tibble::tibble(file = character(), row = integer(), field = character(), value = character(), problem = character()),
    problems
  ) |>
    dplyr::distinct() |>
    dplyr::arrange(file, row, field)
}

#' Stop with a readable report if the metadata is invalid
assert_valid_metadata <- function(datasets, parameters, schema) {
  problems <- validate_metadata(datasets, parameters, schema)
  if (nrow(problems) > 0) {
    report <- stringr::str_glue_data(
      problems,
      "{file}:{row} [{field}] {problem}{ifelse(is.na(value), '', paste0(': \"', value, '\"'))}"
    )
    stop("Invalid metadata (", nrow(problems), " problems):\n", paste(report, collapse = "\n"), call. = FALSE)
  }
  invisible(TRUE)
}

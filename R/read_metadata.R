#' Read the metadata schema
#'
#' @param dir Directory containing `schema.yaml`.
#' @return The parsed schema as a list.
read_schema <- function(dir = "metadata") {
  yaml::read_yaml(file.path(dir, "schema.yaml"))
}

#' Normalise text for searching: lower case, umlauts spelled out (ä = ae),
#' other accents removed, punctuation replaced by spaces, padded with one space
#' on each side so terms can be matched at word starts (" term").
#' Mirrored by `normalise()` in assets/agt.js.
normalise_text <- function(x) {
  x <- stringr::str_to_lower(dplyr::coalesce(as.character(x), ""))
  x <- stringr::str_replace_all(x, c("ä" = "ae", "ö" = "oe", "ü" = "ue", "ß" = "ss"))
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  x <- stringr::str_squish(stringr::str_replace_all(x, "[^a-z0-9]+", " "))
  paste0(" ", x, " ")
}

#' Read the bilingual search dictionary
#'
#' @return A list of concepts, each a list with `en` and `de` character vectors.
read_dictionary <- function(dir = "metadata") {
  yaml::read_yaml(file.path(dir, "dictionary.yaml"))
}

#' Dictionary as a list of normalised term vectors (one per concept), for the JS search
dictionary_terms <- function(dictionary) {
  purrr::map(dictionary_concepts(dictionary), \(concept) unique(stringr::str_trim(normalise_text(c(concept$en, concept$de)))))
}

#' Concept entries of the dictionary (entries with `en`/`de` terms)
dictionary_concepts <- function(dictionary) {
  purrr::keep(dictionary, \(entry) !is.null(entry$en) || !is.null(entry$de))
}

#' Normalised words of a special dictionary entry (`ignore` or `suffixes`)
dictionary_words <- function(dictionary, key) {
  words <- unlist(purrr::map(dictionary, key))
  unique(stringr::str_trim(normalise_text(words)))
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

#' Bounding box per row: the row's own bbox_* if complete, otherwise the box of
#' its `coverage_spatial` region from the schema (NA if neither exists)
merged_bbox <- function(merged, schema) {
  sides <- c("bbox_west", "bbox_south", "bbox_east", "bbox_north")
  own <- purrr::map(sides, \(side) {
    v <- if (side %in% names(merged)) merged[[side]] else rep(NA, nrow(merged))
    suppressWarnings(as.numeric(v))
  })
  has_own <- Reduce(`&`, purrr::map(own, \(v) !is.na(v)))
  coverage <- if ("coverage_spatial" %in% names(merged)) merged$coverage_spatial else rep(NA_character_, nrow(merged))
  region <- schema$regions[coverage]
  out <- purrr::imap(sides, \(side, i) {
    from_region <- unname(purrr::map_dbl(region, \(r) if (is.null(r)) NA_real_ else as.numeric(r[[i]])))
    dplyr::if_else(has_own, own[[i]], from_region)
  })
  tibble::as_tibble(purrr::set_names(out, sides))
}

#' Read the access snippets (metadata/snippets/<id>.R / .py)
read_snippets <- function(dir) {
  files <- list.files(dir, pattern = "\\.(R|py)$", full.names = TRUE)
  tibble::tibble(
    id = tools::file_path_sans_ext(basename(files)),
    language = tolower(tools::file_ext(files)),
    code = purrr::map_chr(files, \(f) paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
  )
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

  snippet_dir <- file.path(dir, "snippets")
  if (validate) {
    assert_valid_metadata(datasets, parameters, schema, snippet_dir)
    dictionary_problems <- validate_dictionary(read_dictionary(dir))
    if (length(dictionary_problems) > 0) {
      stop("Invalid dictionary.yaml:\n", paste(dictionary_problems, collapse = "\n"), call. = FALSE)
    }
  }

  temporal_levels <- vocab_keys(schema, "temporal_resolution")
  current_year <- as.integer(format(Sys.Date(), "%Y"))

  variable_labels <- vocab_labels(schema, "variable")
  snippets <- read_snippets(snippet_dir)
  snippet_of <- function(ids, language) {
    s <- snippets[snippets$language == language, ]
    s$code[match(ids, s$id)]
  }

  merged <- merge_metadata(datasets, parameters)
  bbox <- merged_bbox(merged, schema)
  merged[names(bbox)] <- bbox

  merged |>
    dplyr::mutate(
      variable_label = unname(variable_labels[variable]),
      snippet_r = snippet_of(id, "r"),
      snippet_py = snippet_of(id, "py"),
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

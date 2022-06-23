unique_headers_clean <- function(complex_headers, as_character_vector = FALSE) {
  headers_clean <- complex_headers |>
    purrr::chuck(1) |>
    dplyr::group_by(name) |>
    dplyr::distinct(value) |>
    dplyr::mutate(value = stringr::str_replace_all(value, " ", "_")) |>
    dplyr::summarise(column_names = stringr::str_c(value, collapse = "-")) |>
    dplyr::select(-name)

  if (as_character_vector) {
    headers_clean <- headers_clean |>
      dplyr::pull(column_names)
  }

  return(headers_clean)
}

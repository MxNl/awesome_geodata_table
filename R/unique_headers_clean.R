unique_headers_clean <- function(complex_headers, as_character_vector = FALSE) {
  headers_clean <- complex_headers |>
    purrr::chuck(1) |>
    group_by(name) |>
    distinct(value) |>
    mutate(value = stringr::str_replace_all(value, " ", "_")) |>
    summarise(column_names = stringr::str_c(value, collapse = "-")) |>
    select(-name)

  if (as_character_vector) {
    headers_clean <- headers_clean |>
      pull(column_names)
  }

  return(headers_clean)
}

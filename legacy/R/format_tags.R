format_tags <- function(x) {
  x |>
    dplyr::mutate(
      Tags = stringr::str_remove_all(Tags, " "),
      Tags = stringr::str_replace_all(Tags, ",", ", "),
      Tags = stringr::str_to_lower(Tags)
    )
}

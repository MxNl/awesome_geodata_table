format_tags <- function(x) {
  x |>
    dplyr::mutate(Tags = stringr::str_replace_all(Tags, ", ", ",\n"))
}

format_tags <- function(x) {
  x |>
    mutate(Tags = stringr::str_replace_all(Tags, ", ", ",\n"))
}

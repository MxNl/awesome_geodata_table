read_column_types <- function(path) {
  path |>
    readr::read_lines(n_max = 1) |>
    stringr::str_remove_all(";")
}

read_column_types <- function() {
  CSV_TABLE_PATH |>
    readr::read_lines(n_max = 1) |>
    stringr::str_remove_all(";")
}

awesome_geodata_table_read <- function() {

  path <- here::here("inst", "extdata", "awesome_geodata_table.csv")

  coltypes <- readr::read_lines(path, n_max = 1) |>
    stringr::str_remove_all(";")

    # "cfffffffDDffficcffffffff"

  readr::read_csv2(
    path,
    col_types = coltypes,
    skip = 3)
}

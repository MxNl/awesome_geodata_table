awesome_geodata_table_read <- function() {

  path <- here::here("inst", "extdata", "awesome_geodata_table.csv")

  coltypes <- path |>
    read_column_types()

  readr::read_csv2(
    path,
    col_types = coltypes,
    skip = 3)
}

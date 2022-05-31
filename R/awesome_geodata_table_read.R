awesome_geodata_table_read <- function() {

  path <- here::here("inst", "extdata", "awesome_geodata_table.csv")

  coltypes <- "fffffffDDffficcffffffff"

  readr::read_csv2(
    path,
    col_types = coltypes,
    skip = 2)
}

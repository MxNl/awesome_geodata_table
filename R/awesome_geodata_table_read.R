#' read table
#'
#' @param filepath filepath.
#' @return a tibble.
#' @export
#'
awesome_geodata_table_read <- function(filepath) {

  coltypes <- read_column_types()

  readr::read_csv2(
    filepath,
    col_types = coltypes,
    skip = 3)
}

get_table_header_csv <- function() {
  CSV_TABLE_PATH |>
    readr::read_csv2(
      col_names = FALSE,
      n_max = 4,
      show_col_types = FALSE, locale = readr::locale(decimal_mark = ",", grouping_mark = ".")
    )
}
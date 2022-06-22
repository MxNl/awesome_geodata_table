merge_new_entries <- function (filepath) {
  table_old <- CSV_TABLE_PATH |>
    awesome_geodata_table_read()

  unique_header_clean <- CSV_TABLE_PATH |>
    complex_header() |>
    unique_headers_clean() |>
    dplyr::pull(column_names)

  table_old <- table_old |>
    purrr::set_names(unique_header_clean)

  new_entries <- "inst/extdata/new_entries" |>
    list.files(full.names = TRUE, pattern = "*.txt") |>
    map_df(read_new_entry) |>
    readr::type_convert(col_types = true_column_types())

  table_old |>
    dplyr::bind_rows(new_entries)
}
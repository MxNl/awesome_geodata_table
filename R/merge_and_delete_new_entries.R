merge_and_delete_new_entries <- function (filepath) {
  table_old <- CSV_TABLE_PATH |>
    awesome_geodata_table_read() |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

  unique_header_clean <- CSV_TABLE_PATH |>
    complex_header() |>
    unique_headers_clean(as_character_vector = TRUE)

  table_old <- table_old |>
    purrr::set_names(unique_header_clean)

  new_entry_files <- list_new_entry_files()

  new_rows <- new_entry_files |>
    purrr::map_df(read_new_entry) |>
    tidyr::separate_rows(Parameter, sep = ",") |>
    dplyr::mutate(Parameter = stringr::str_squish(Parameter)) |>
    readr::type_convert(col_types = true_column_types()) |>
    dplyr::mutate(across(everything(), as.character))

  get_table_header_csv() |>
    purrr::set_names(unique_header_clean) |>
    dplyr::bind_rows(table_old) |>
    dplyr::bind_rows(new_rows) |>
    readr::write_csv2(CSV_TABLE_PATH, col_names = FALSE)

  new_entry_files |>
    unlink()
}
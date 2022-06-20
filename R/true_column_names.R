true_column_names <- function(filepath) {
  complex_header(CSV_TABLE_PATH) |>
    unique_headers_clean(as_character_vector = TRUE)
}

agt_configure <- function(table_data, double_column_names, column_types) {
  header_sketch <- complex_header(double_column_names)

  headers_multi_level <- header_sketch |>
    unique_headers_clean(as_character_vector = TRUE)

  show_main <- which(headers_multi_level %in% c(
    "Parameter",
    "Dataset name",
    "Tags",
    "Domain",
    "Resolution-temporal-min",
    "Resolution-temporal-max",
    "Resolution-spatial-min_[m]",
    "Resolution-spatial-max_[m]",
    "Coverage-temporal-start",
    "Coverage-temporal-end",
    "Coverage-spatial-spatial",
    "Data_type",
    "Data_format"
  ))

  hide_main <- which(headers_multi_level %in% headers_multi_level[-show_main])

  list(
    header_sketch,
    headers_multi_level,
    show_main,
    hide_main
  ) %>%
    set_names(
      c(
        "header_sketch",
        "headers_multi_level",
        "show_main",
        "hide_main"
      ))
}
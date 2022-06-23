format_utf8_critical_characters <- function(x) {
  x |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        stringr::str_replace_all,
        c(
          "<" = "<"
        )
      )
    ) |>
    readr::type_convert(col_types = true_column_types())
}
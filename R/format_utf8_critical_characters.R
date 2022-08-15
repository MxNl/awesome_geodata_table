format_utf8_critical_characters <- function(x, column_types) {
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
    readr::type_convert(col_types = column_types)
}
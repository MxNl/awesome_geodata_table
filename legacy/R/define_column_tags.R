define_column_tags <- function(columns) {
  selected_columns <- columns %>%
    dplyr::filter(stringr::str_detect(name, "^Tags$"))

  selected_columns %>%
    dplyr::rowwise() |>
      dplyr::group_split() %>%
    purrr::map(
      ~reactable::colDef(
        fontS
      )
    ) %>%
    purrr::set_names(selected_columns %>% pull(name))
}
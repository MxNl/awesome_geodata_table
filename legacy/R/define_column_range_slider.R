define_column_range_slider <- function (columns) {
  selected_columns <- columns |>
    dplyr::filter(type %in% c("n", "i"))

  selected_columns %>%
    dplyr::rowwise() |>
      dplyr::group_split() %>%
    purrr::map(
      ~reactable::colDef(
        filterMethod = js_filterMinValue,
        filterInput = js_rangeFilter
      )
    ) %>%
    purrr::set_names(selected_columns %>% pull(name))
}
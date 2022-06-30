define_column_comment <- function(columns) {
  selected_columns <- columns %>%
    dplyr::filter(stringr::str_detect(name, "Comment"))

  selected_columns %>%
    dplyr::rowwise() |>
      dplyr::group_split() %>%
    purrr::map(
      ~reactable::colDef(
        cell = function(value, index, name) {
          render_reactable_cell_with_tippy(text = value, tooltip = value) }
      )
    ) %>%
    purrr::set_names(selected_columns %>% pull(name))
}
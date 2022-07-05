define_column_binary <- function(columns) {
  selected_columns <- columns %>%
    dplyr::filter(stringr::str_detect(name, "Version updates"))

  selected_columns %>%
    dplyr::rowwise() |>
      dplyr::group_split() %>%
    purrr::map(
      ~reactable::colDef(
        cell = function(value) {
          # Render as an X mark or check mark
          if (value == "no") {
            render_reactable_cell_with_tippy(text = "\u274c", tooltip = value)
          } else if (value == "yes") {
            render_reactable_cell_with_tippy(text = "\u2714\ufe0f", tooltip = value)
          } else if (is.na(value)) {
            "unknown"
          } else value
        }
      )
    ) %>%
    purrr::set_names(selected_columns %>% pull(name))
}
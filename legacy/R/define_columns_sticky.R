define_columns_sticky <- function (columns) {
  selected_columns <- columns %>%
    dplyr::filter(name %in% c("Dataset name", "Parameter"))

  selected_columns %>%
    dplyr::rowwise() |>
      dplyr::group_split() %>%
    purrr::map(
      ~reactable::colDef(
        sticky = "left",
        minWidth = 200
        # style = sticky_style,
        # headerStyle = sticky_style
      )
    ) %>%
    purrr::set_names(selected_columns %>% pull(name))
}
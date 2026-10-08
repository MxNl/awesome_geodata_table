define_column_latex <- function(columns) {
  selected_columns <- columns %>%
    dplyr::filter(stringr::str_detect(name, "^Unit$"))

  selected_columns %>%
    dplyr::rowwise() |>
      dplyr::group_split() %>%
    purrr::map(
      ~reactable::colDef(
        cell = function(value) {
          ifelse(
            value %in% c("categorical", "ordinal") | is.na(value),
            value,
            as.character(stringr::str_glue("$${value}$$"))
          )
        }
      )
    ) %>%
    purrr::set_names(selected_columns %>% pull(name))
}
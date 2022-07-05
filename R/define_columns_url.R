define_columns_url <- function(columns) {
  selected_columns <- columns %>%
    dplyr::filter(stringr::str_detect(name, "Download|Literature"))

  selected_columns %>%
    dplyr::rowwise() |>
      dplyr::group_split() %>%
    purrr::map(
      ~reactable::colDef(
        cell = function(value, index) {
          if (stringr::str_detect(value, "http") | is.na(value)) {
            htmltools::tags$a(href = value, target = "_blank", "link")
          } else {
            "no link yet"
          }
        }
      )
    ) %>%
    purrr::set_names(selected_columns %>% pull(name))
}
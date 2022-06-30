format_equations <- function(x) {
  x %>%
    dplyr::mutate(
      Unit = dplyr::if_else(
        Unit %in% c("categorical", "ordinal") | is.na(Unit),
        Unit,
        as.character(stringr::str_glue("$${Unit}$$"))
      )
    )
}
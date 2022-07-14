get_column_types <- function(x) {
  x %>%
    slice(1) %>%
    unlist() %>%
    unname() %>%
    stringr::str_c(collapse = "")
}

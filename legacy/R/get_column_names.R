get_column_names <- function(x) {
  x %>%
    slice(3) %>%
    unlist() %>%
    unname()
}

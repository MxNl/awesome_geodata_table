agt_table <- function (x) {

  column_names <- get_column_names(x)

  x %>%
    slice(-(1:3)) %>%
    set_names(column_names)
}
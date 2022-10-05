collect_userinput_in_tibble <- function(input) {
  id_exclude <- c("button_send", "shiny_alert")
  id_include <- setdiff(names(input), id_exclude)
  if (length(id_include) > 0) {
    input_values <- NULL
    for (i in id_include) {
      input_values <- as.data.frame(
        rbind(
          input_values,
          cbind(
            i,
            if (is.null(input[[i]])) { NA } else { input[[i]] }
          )
        )
      )
    }
  }
  names(input_values) <- c("name", "value")
  input_values %>%
    group_by(name) %>%
    mutate(
      name = ifelse(row_number() == 1 & n() == 2, "start", name),
      name = ifelse(row_number() == 2 & n() == 2, "end", name)
    ) %>%
    pivot_wider() %>%
    mutate(across(all_of(c("start", "end")), as_date))
}
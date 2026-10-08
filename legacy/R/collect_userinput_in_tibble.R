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
            if (is.null(input[[i]])) {
              NA
            } else {
              input[[i]] %>% as.character()
            }
          )
        )
      )
    }
  }
  # print(input_values)
  names(input_values) <- c("name", "value")

  # print(input_values)
  # input_values %>% dput()

  input_values |>
    group_by(name) |>
    mutate(
      name = ifelse(row_number() == 1 & name == "start_end", "start", name),
      name = ifelse(row_number() == 2 & name == "start_end", "end", name)
    ) |>
    group_by(name) |>
    summarise(value = value |>
      stringr::str_squish() |>
      stringr::str_c(collapse = ", ")
    ) |>
    pivot_wider() |>
    mutate(across(all_of(c("start", "end")), as_date))
}
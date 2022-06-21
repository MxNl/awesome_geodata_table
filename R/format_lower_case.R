format_lower_case <- function(x) {
  x |>
    mutate(
      across(
        all_of(
          c(
            "Parameter"
          )
        ),
      stringr::str_to_lower
      )
    )
}
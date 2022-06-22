format_lower_case <- function(x) {
  x |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(
          c(
            "Parameter"
          )
        ),
      stringr::str_to_lower
      )
    )
}
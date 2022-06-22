read_new_entry <- function (filepath) {
  readr::read_lines(filepath) |>
    dplyr::as_tibble() |>
    dplyr::mutate(
      name = stringr::word(value, end = 1, sep = ": "),
      value = stringr::word(value, start = 2, sep = ": "),
    ) |>
    tidyr::pivot_wider()
}
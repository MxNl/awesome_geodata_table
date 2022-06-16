read_new_entry <- function (filepath) {
  readr::read_lines(filepath) %>%
    as_tibble() %>%
    mutate(
      name = stringr::word(value, end = 1, sep = ": "),
      value = stringr::word(value, start = 2, sep = ": "),
    ) %>%
    pivot_wider()
}
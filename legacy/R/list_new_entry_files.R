list_new_entry_files <- function () {
  NEW_ENTRY_DIRECTORY |>
    list.files(full.names = TRUE, pattern = "*.txt") |>
    purrr::discard(stringr::str_detect, "/example.txt$")
}
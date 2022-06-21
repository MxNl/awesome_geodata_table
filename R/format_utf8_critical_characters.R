format_utf8_critical_characters <- function(x) {
  x |>
    mutate(
      across(
        everything(),
        stringr::str_replace_all, "<", "<"
      )
    )
}
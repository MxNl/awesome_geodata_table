format_link <- function(x) {
  x |>
    mutate(
      across(
        contains("link"),
        ~ stringr::str_c("<a href='", .x, "'>", "link", "</a>")
        )
      )
}

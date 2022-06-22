format_link <- function(x) {
  x |>
    dplyr::mutate(
      dplyr::across(
        dplyr::contains("link"),
        ~ stringr::str_c("<a href='", .x, "'>", "link", "</a>")
        )
      )
}

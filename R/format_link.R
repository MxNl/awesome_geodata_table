format_link <- function(x) {
  x |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(c("Download", "Literature")),
        ~ stringr::str_c("<a href='", .x, "'>", "link", "</a>")
        )
      )
}

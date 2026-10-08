format_comment <- function(x) {
  x |>
    dplyr::mutate(Comment = tidyr::replace_na(Comment, "No comment yet."))
}

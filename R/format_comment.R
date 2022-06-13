format_comment <- function(x) {
  x |>
    mutate(Comment = tidyr::replace_na(Comment, "No comment yet."))
}

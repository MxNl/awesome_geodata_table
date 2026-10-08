format_resolution <- function(x) {
  x |>
  dplyr::mutate(dplyr::across(dplyr::all_of(c("min", "max")), stringr::str_replace_all, "<=", "&#8804;")) |>
  dplyr::mutate(dplyr::across(dplyr::all_of(c("min", "max")), stringr::str_replace_all, "-", "&#8211;")) |>
  dplyr::mutate(dplyr::across(dplyr::all_of(c("min", "max")), factor))
}

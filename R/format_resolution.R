format_resolution <- function(x) {
  x |>
  mutate(across(all_of(c("min", "max")), stringr::str_replace_all, "<=", "&#8804;")) |>
  mutate(across(all_of(c("min", "max")), stringr::str_replace_all, "-", "&#8211;")) |>
  mutate(across(all_of(c("min", "max")), factor))
}

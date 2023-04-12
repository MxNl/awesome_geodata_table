generate_filter_specs <- function(x) {
  list(
    filter_choices_datasetname = unique_sorted(x$`Dataset name`),
    filter_choices_parameter = unique_sorted(x$Parameter),
    filter_choices_tags = get_comma_sep_unique_values(x$Tags),
    filter_choices_domain = unique_sorted(x$Domain),
    filter_choices_spatcov = unique_sorted(x$`Coverage (spatial)`),
    spatial_res_range = c(x$`min [m]`, x$`max [m]`) %>%
      range(na.rm = TRUE),
    temporal_cov_range = c(x$start, x$end) %>%
      range(na.rm = TRUE) %>%
      year(),
    temporal_res_unique = INPUT_CHOICES_TEMPRES %>% discard(str_detect, "static")
  )
}
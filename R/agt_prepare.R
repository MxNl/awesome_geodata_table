agt_prepare <- function(x, column_types) {
  x %>%
    format_utf8_critical_characters(column_types) |>
      # format_link() |>
      format_tags() |>
      # format_colwidth_workaround() |>
      format_lower_case() |>
      # format_resolution() |>
      format_comment() |>
      format_version_update() %>%
      format_domain() %>%
      # format_equations() %>%
      set_levels(min, INPUT_CHOICES_TEMPRES) |>
      set_levels(max, INPUT_CHOICES_TEMPRES) |>
      impute_tags()
}


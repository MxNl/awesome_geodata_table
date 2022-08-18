agt_prepare <- function(x, column_types) {
  x %>%
    format_utf8_critical_characters(column_types) |>
      # format_link() |>
      format_tags() |>
      # format_colwidth_workaround() |>
      format_lower_case() |>
      # format_resolution() |>
      format_comment() |>
      # format_equations() %>%
      set_levels(min, COLUMN_CATEGORIES_TEMPRES) %>%
      set_levels(max, COLUMN_CATEGORIES_TEMPRES) %>%
    impute_tags()
}


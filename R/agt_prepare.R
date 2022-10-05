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
      set_levels(min, column_categories_tempres) %>%
      set_levels(max, column_categories_tempres) %>%
    impute_tags()
}


generate_input_choices <- function(x) {
  list(
    input_choices_parameter = unique_sorted(x$Parameter),
    input_choices_tags = get_comma_sep_unique_values(x$Tags),
    input_choices_unit = unique_sorted(x$Unit),
    input_choices_tempres = column_categories_tempres,
    input_choices_spatialmin = unique_sorted(x$`min [m]`),
    input_choices_spatialmax = unique_sorted(x$`max [m]`),
    input_choices_spatialvertical = unique_sorted(x$vertical)
  )
}
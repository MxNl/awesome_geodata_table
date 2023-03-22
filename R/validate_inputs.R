validate_inputs <- function() {
  # Required Fields
  required_iv <- InputValidator$new()
  required_iv$add_rule("Parameter", sv_required())
  required_iv$add_rule("Dataset name", sv_required())
  required_iv$add_rule("Download", sv_required())
  # required_iv$enable()

  # Format
  download_iv <- InputValidator$new()
  download_iv$condition(~input_provided(input$Download))
  download_iv$add_rule("Download", sv_url(allow_na = TRUE))
  # download_iv$enable()
  #
  literature_iv <- InputValidator$new()
  literature_iv$condition(~input_provided(input$Literature))
  literature_iv$add_rule("Literature", sv_url(allow_na = TRUE))
  # literature_iv$enable()
  #
  dataset_name_iv <- InputValidator$new()
  dataset_name_iv$condition(~input_provided(input$`Dataset name`))
  dataset_name_iv$add_rule("Dataset name", sv_regex(
    "[a-zA-Z]",
    "The dataset name must contain at least one letter"))
  # dataset_name_iv$enable()

  parameter_iv <- InputValidator$new()
  parameter_iv$condition(~input_provided(input$Parameter))
  parameter_iv$add_rule("Parameter", sv_regex(
    "[a-zA-Z]",
    "The dataset name must contain at least one letter"))

  start_end_iv <- InputValidator$new()
  start_end_iv$condition(~input_provided(input$start_end))
  start_end_iv$add_rule("start_end", sv_date_order())

  iv <- InputValidator$new()
  iv$add_validator(required_iv)
  iv$add_validator(download_iv)
  iv$add_validator(literature_iv)
  iv$add_validator(dataset_name_iv)
  iv$add_validator(parameter_iv)
  iv$add_validator(start_end_iv)
  iv$enable()
}
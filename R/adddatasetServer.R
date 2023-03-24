adddatasetServer <- function(id, table_data, input_choices) {
  moduleServer(id, function(input, output, session) {

    updateSelectizeInput(
      session,
      "Coordinate reference system",
      choices = input_choices$input_choices_coordrefsys,
      selected = character(0),
      server = TRUE
    )

    table_data_empty <- table_data %>%
      slice(0) %>%
      mutate(across(everything(), as.character))

    # observeEvent(input$Dataset, { no_letters_feedback(input$Dataset, "Dataset") })
    # observeEvent(input$Parameter, { no_letters_feedback(input$Parameter, "Parameter") })
    # observeEvent(input$Tags, { no_letters_feedback(input$Tags, "Tags") })
    # observeEvent(input$Unit, { no_letters_feedback(input$Unit, "Unit") })
    # observeEvent(input$start_end, { date_order_feedback(input$start_end) })

    observeEvent(input$button_send, {
      if (iv$is_valid()) {

        input_values <- collect_userinput_in_tibble(input) %>%
          mutate(across(everything(), as.character)) %>%
          bind_rows(table_data_empty, .)

        #TODO delete
        print(input_values %>% names())
        print(input_values)

        input_values %>%
          select(-any_of("shinyalert")) %>%
          sheet_append(
            ss = "18V8HpVDG3BVBxv03jbg-m1ZCnbz3R7t4Asty_Ub_tfw"
          )

        shinyalert(
          "Thank you!",
          "Your dataset entry has been added to AwesomeGeodataTable.
    Thanks a lot for contributing.
    If you want to add more parameters of the same dataset, please just continue with the prefilled values...",
          type = "success")
      } else {
        shinyalert(
          "Ooops!",
          "Please check if your provided inputs are correct!",
          type = "error")
      }
    })

    # Input validation
    # Required Fields
    required_iv <- InputValidator$new()
    required_iv$add_rule("Parameter", sv_required())
    required_iv$add_rule("Dataset name", sv_required())
    required_iv$add_rule("Download", sv_required())
    required_iv$add_rule("Tags", sv_required())
    required_iv$add_rule("Domain", sv_required())
    required_iv$add_rule("Unit", sv_required())
    required_iv$add_rule("min", sv_required())
    required_iv$add_rule("max", sv_required())
    required_iv$add_rule("min [m]", sv_required())
    required_iv$add_rule("max [m]", sv_required())
    required_iv$add_rule("start_end", sv_required())
    required_iv$add_rule("Coverage (spatial)", sv_required())
    # required_iv$enable()

    # Format
    download_iv <- InputValidator$new()
    download_iv$condition(~input_provided(input$Download))
    download_iv$add_rule("Download", sv_url(allow_na = TRUE))
    # download_iv$enable()

    literature_iv <- InputValidator$new()
    literature_iv$condition(~input_provided(input$Literature))
    literature_iv$add_rule("Literature", sv_url(allow_na = TRUE))
    # literature_iv$enable()

    dataset_name_iv <- InputValidator$new()
    dataset_name_iv$condition(~input_provided(input$`Dataset name`))
    dataset_name_iv$add_rule("Dataset name", sv_regex(
      "[a-zA-Z]",
      "The dataset name must contain at least one letter")
    )
    # dataset_name_iv$enable()

    parameter_iv <- InputValidator$new()
    parameter_iv$condition(~input_provided(input$Parameter))
    parameter_iv$add_rule("Parameter", sv_regex(
      "[a-zA-Z]",
      "The dataset name must contain at least one letter")
    )

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
  })
}
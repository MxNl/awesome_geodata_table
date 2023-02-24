adddatasetServer <- function(id, table_data, input_choices) {
  moduleServer(id, function(input, output, session) {

    updateSelectizeInput(
      session,
      "coord_refsys",
      choices = input_choices$input_choices_coordrefsys,
      selected = character(0),
      server = TRUE
    )

    table_data_empty <- table_data %>%
      slice(0) %>%
      mutate(across(everything(), as.character))

    observeEvent(input$Dataset, { no_letters_feedback(input$Dataset, "Dataset") })
    observeEvent(input$Parameter, { no_letters_feedback(input$Parameter, "Parameter") })
    observeEvent(input$Tags, { no_letters_feedback(input$Tags, "Tags") })
    observeEvent(input$Unit, { no_letters_feedback(input$Unit, "Unit") })
    observeEvent(input$start_end, { date_order_feedback(input$start_end) })

    observeEvent(input$button_send, {

      input_values <- collect_userinput_in_tibble(input) %>%
        mutate(across(everything(), as.character)) %>%
        bind_rows(table_data_empty, .)

      input_values %>%
        sheet_append(
          ss = "18V8HpVDG3BVBxv03jbg-m1ZCnbz3R7t4Asty_Ub_tfw"
        )

      shinyalert(
        "Thank you!",
        "Your dataset entry has been added to AwesomeGeodataTable.
  Thanks a lot for contributing.
  If you want to add more parameters of the same dataset, please just continue with the prefilled values...",
        type = "success")
    })

    download_iv <- InputValidator$new()
    download_iv$condition(~isTruthy(input$Download))
    download_iv$add_rule("Download", sv_url(allow_na = TRUE))
    # iv$add_rule("email", sv_required())
    # iv$add_rule("email", sv_email())
    download_iv$enable()

    literature_iv <- InputValidator$new()
    literature_iv$condition(~isTruthy(input$Literature))
    literature_iv$add_rule("Literature", sv_url(allow_na = TRUE))
    # iv$add_rule("email", sv_required())
    # iv$add_rule("email", sv_email())
    literature_iv$enable()
  })
}
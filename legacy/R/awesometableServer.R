awesometableServer <- function(id, table_data) {
  moduleServer(id, function(input, output, session) {

    output$n_search_results <- renderValueBox({
      valueBox(
        as.character(nrow(table_data)),
        "Found Parameters",
        icon("check-circle"),
        color = "yellow"
      )
    })

    output$n_search_datasets <- renderValueBox({
      valueBox(
        table_data$`Dataset name` %>%
          unique() %>%
          length() %>%
          as.character(),
        "Found Datasets",
        icon("database"),
        color = "yellow"
      )
    })


    output$download_data <- downloadHandler(
      filename = function() {
        paste('awesome-geodata-table_results_', Sys.Date(), '.csv', sep = '')
      },
      content = function(con) {
        table_data %>%
          select(-contains("_icon")) %>%
          write.csv2(con)
      }
    )

    observeEvent(input$spatial_res, {
      updateAutonumericInput(
        session,
        "spatial_res_num",
        value = input$spatial_res
      )
    })
    observeEvent(input$spatial_res_num, {
      updateSliderInput(
        session,
        "spatial_res",
        value = input$spatial_res_num)
    })

    observeEvent(input$temporal_res, {
      updateSelectizeInput(
        session,
        "temporal_res_num",
        selected = input$temporal_res
      )
    })

    observeEvent(input$temporal_res_num, {
      updateSliderTextInput(
        session,
        "temporal_res",
        selected = input$temporal_res_num)
    })

    output$table <- renderReactable({
      columns_to_show <- if(input$column_visibility_toggle) {
        COLUMNS_TOGGLE_INVISIBLE %>%
          purrr::map(~TRUE)
      } else {
        COLUMNS_TOGGLE_INVISIBLE
      }
      agt_html(table_data, columns_to_show)
    })

    ### This part is reapeted from above TODO find solution to clean this up
    table_filtered <- reactive({
      # Filter data
      temporal_res_keep <- INPUT_CHOICES_TEMPRES[
        1:which(INPUT_CHOICES_TEMPRES == input$temporal_res)
      ] %>%
        c("static")

      temporal_coverage_date <- c(input$temporal_coverage[1], input$temporal_coverage[2] + 1) %>%
        str_c("-01-01") %>%
        ymd()

      table_data %>%
        filter(
          conditional(length(input$`Dataset name`) > 0, `Dataset name` %in% input$`Dataset name`),
          conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter),
          conditional(length(input$spatial_coverage) > 0, `Coverage (spatial)` %in% input$spatial_coverage),
          conditional(length(input$Tags) > 0, str_detect(Tags, str_c(input$Tags, collapse = "|"))),
          conditional(length(input$Domain) > 0, Domain %in% input$Domain),
          conditional(length(input$spatial_res) > 0, (`max [m]` <= input$spatial_res | is.na(`max [m]`))),
          conditional(length(input$temporal_coverage) > 0, (start <= temporal_coverage_date[1] | is.na(start)) & (end >= temporal_coverage_date[2] | is.na(end))),
          conditional(length(input$temporal_res) > 0, max %in% temporal_res_keep)
        )
    })
    ###

    output$n_search_results <- renderValueBox({
        valueBox(
          as.character(nrow(table_filtered())),
          "Found Parameters",
          # icon("check-circle"),
          color = "yellow"
        )
      })

      output$n_search_datasets <- renderValueBox({
        valueBox(
          table_filtered()$`Dataset name` %>%
            unique() %>%
            length() %>%
            as.character(),
          "Found Datasets",
          # icon("check-circle"),
          color = "yellow"
        )
      })

    observeEvent(input$button_filter, {
      # updateReactable(
      #   "table",
      #   data = table_filtered,
      #   expanded = TRUE
      # )
      # Filter data
      temporal_res_keep <- INPUT_CHOICES_TEMPRES[
        1:which(INPUT_CHOICES_TEMPRES == input$temporal_res)
      ] %>%
        c("static")

      temporal_coverage_date <- c(input$temporal_coverage[1], input$temporal_coverage[2] + 1) %>%
        str_c("-01-01") %>%
        ymd()

      table_filtered <- table_data %>%
        filter(
          conditional(length(input$`Dataset name`) > 0, `Dataset name` %in% input$`Dataset name`),
          conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter),
          conditional(length(input$spatial_coverage) > 0, `Coverage (spatial)` %in% input$spatial_coverage),
          conditional(length(input$Tags) > 0, str_detect(Tags, str_c(input$Tags, collapse = "|"))),
          conditional(length(input$Domain) > 0, Domain %in% input$Domain),
          conditional(length(input$spatial_res) > 0, (`max [m]` <= input$spatial_res | is.na(`max [m]`))),
          conditional(length(input$temporal_coverage) > 0, (start <= temporal_coverage_date[1] | is.na(start)) & (end >= temporal_coverage_date[2] | is.na(end))),
          conditional(length(input$temporal_res) > 0, max %in% temporal_res_keep)
        )

      output$table <- renderReactable({
        columns_to_show <- if(input$column_visibility_toggle) {
        COLUMNS_TOGGLE_INVISIBLE %>%
          purrr::map(~TRUE)
      } else {
        COLUMNS_TOGGLE_INVISIBLE
      }
        agt_html(table_filtered, columns_to_show)
      })

      output$download_data <- downloadHandler(
        filename = function() {
          paste('awesome-geodata-table_results_', Sys.Date(), '.csv', sep = '')
        },
        content = function(con) {
          table_filtered %>%
            select(-contains("_icon")) %>%
            write.csv2(con)
        }
      )
    })
  })
}
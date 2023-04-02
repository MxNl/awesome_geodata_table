awesometableServer <- function(id, table_data) {
  moduleServer(id, function(input, output, session) {

    output$table <- renderReactable({
      agt_html(table_data)
    })

    output$n_search_results <- renderValueBox({
        valueBox(
          as.character(nrow(table_data)),
          "Found Parameters",
          # icon("check-circle"),
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
          # icon("check-circle"),
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

    observeEvent(input$button_filter, {
      # Filter data
      temporal_res_keep <- column_categories_tempres[
        which(column_categories_tempres == input$temporal_res[1]):
          which(column_categories_tempres == input$temporal_res[2])
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
          conditional(length(input$spatial_res) > 0, (`min [m]` >= input$spatial_res[1] | is.na(`min [m]`)) & (`max [m]` <= input$spatial_res[2] | is.na(`max [m]`))),
          conditional(length(input$temporal_coverage) > 0, (start <= temporal_coverage_date[1] | is.na(start)) & (end >= temporal_coverage_date[2] | is.na(end))),
          conditional(length(input$temporal_res) > 0, min %in% temporal_res_keep & max %in% temporal_res_keep)
        )
      # updateReactable(
      #   "table",
      #   data = table_filtered,
      #   expanded = TRUE
      # )
      output$n_search_results <- renderValueBox({
        valueBox(
          as.character(nrow(table_filtered)),
          "Found Parameters",
          # icon("check-circle"),
          color = "yellow"
        )
      })

      output$n_search_datasets <- renderValueBox({
        valueBox(
          table_filtered$`Dataset name` %>%
            unique() %>%
            length() %>%
            as.character(),
          "Found Datasets",
          # icon("check-circle"),
          color = "yellow"
        )
      })

      output$table <- renderReactable({
        agt_html(table_filtered)
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
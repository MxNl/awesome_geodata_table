awesometableServer <- function(id, table_data) {
  moduleServer(id, function(input, output, session) {

    output$table <- renderReactable({
      agt_html()
    })

    observe({
      # Filter data
      temporal_res_keep <- COLUMN_CATEGORIES_TEMPRES[
        which(COLUMN_CATEGORIES_TEMPRES == input$temporal_res[1]):
          which(COLUMN_CATEGORIES_TEMPRES == input$temporal_res[2])
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
      updateReactable(
        "table",
        data = table_filtered,
        expanded = TRUE
      )

      output$n_search_results <- renderValueBox({
        valueBox(
          as.character(nrow(table_filtered)),
          "Found Parameters",
          # icon("check-circle"),
          "yellow"
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
          "yellow"
        )
      })

      output$download_data <- downloadHandler(
        filename = function() {
          paste('awesome-geodata-table_results_', Sys.Date(), '.csv', sep = '')
        },
        content = function(con) {
          write.csv(table_filtered, con)
        }
      )

      # Update Input choices
      # updateSelectizeInput(
      #   inputId = "Dataset name",
      #   label = "Dataset name",
      #   choices = unique(table_filtered$`Dataset name`) %>% sort()
      # )
      # updateSelectizeInput(
      #   inputId = "Parameter",
      #   label = "Parameter",
      #   choices = unique(table_filtered$Parameter) %>% sort()
      # )
      # updateSelectizeInput(
      #   inputId = "Tags",
      #   label = "Tags",
      #   choices = unique(table_filtered$Tags) %>%
      #     stringr::str_c(collapse = ",") %>%
      #     stringr::str_split(pattern = ",") %>%
      #     unlist() %>%
      #     unique() %>%
      #     sort()
      # )
      # updateSelectizeInput(
      #   inputId = "Domain",
      #   label = "Domain",
      #   choices = unique(table_filtered$Domain) %>% sort()
      # )
      # updateSelectizeInput(
      #   inputId = "spatial_coverage",
      #   label = "Coverage (spatial)",
      #   choices = unique(table_filtered$`Coverage (spatial)`) %>% sort()
      # )
    })

  })
}
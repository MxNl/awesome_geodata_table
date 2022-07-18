awesometableServer <- function(id) {
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

      filtered <- data %>%
        filter(
          conditional(length(input$`Dataset name`) > 0, `Dataset name` %in% input$`Dataset name`),
          conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter),
          conditional(length(input$spatial_coverage) > 0, `Coverage (spatial)` %in% input$spatial_coverage),
          conditional(length(input$Tags) > 0, str_detect(Tags, str_c(input$Tags, collapse = "|"))),
          conditional(length(input$Domain) > 0, Domain %in% input$Domain),
          conditional(length(input$spatial_res) > 0, `min [m]` >= input$spatial_res[1] & `max [m]` <= input$spatial_res[2]),
          conditional(length(input$temporal_coverage) > 0, start >= temporal_coverage_date[1] & end <= temporal_coverage_date[2]),
          conditional(length(input$temporal_res) > 0, min %in% temporal_res_keep & max %in% temporal_res_keep)
        )
      updateReactable(
        "table",
        data = filtered,
        expanded = TRUE
      )
    })

  })
}
awesometableServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$table <- renderReactable({
      agt_html()
    })

    observe({
      # Filter data
      filtered <- data %>%
        filter(
          conditional(length(input$`Dataset name`) > 0, `Dataset name` %in% input$`Dataset name`),
          conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter),
          conditional(length(input$Tags) > 0, str_detect(Tags, str_c(input$Tags, collapse = "|"))),
          conditional(length(input$Domain) > 0, Domain %in% input$Domain),
          conditional(length(input$spatial_res) > 0, `min [m]` >= input$spatial_res[1] & `max [m]` <= input$spatial_res[2])
        )
      updateReactable(
        "table",
        data = filtered,
        expanded = TRUE
      )
    })

  })
}

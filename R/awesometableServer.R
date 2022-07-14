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
          conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter)
        )
      updateReactable(
        "table",
        data = filtered,
        expanded = TRUE
      )
    })

  })
}

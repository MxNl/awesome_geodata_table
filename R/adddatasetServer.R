adddatasetServer <- function(id, table_data) {
  moduleServer(id, function(input, output, session) {

    observe({
      output$'Dataset name' <- renderText(input$'Dataset name')
      output$Parameter <- renderText(input$Parameter)
      output$Domain <- renderText(input$Domain)
    })

    observeEvent(input$button_send, {
      shinyalert(
        "Info!",
        "Your dataset entry has been added to AwesomeGeodataTable.
Thanks a lot for contributing.
If you want to add more parameters of the same dataset, please just continue with the prefilled values...",
        type = "info")
    })

  })
}
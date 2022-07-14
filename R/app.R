library(dplyr)
library(purrr)
library(googlesheets4)
library(stringr)
library(shiny)
library(shinyjs)
library(shinythemes)
library(reactable)
library(reactablefmtr)

awesome_geodata_table_App <- function() {

  table_raw <- agt_raw_read()
  column_types <- get_column_types(table_raw)
  double_column_names <- get_double_column_names(table_raw)
  data <- table_raw %>%
    agt_table() %>%
    agt_prepare(column_types)
  table_config <- agt_configure(data, double_column_names, column_types)
  spatial_res_range <- c(data$`min [m]`, data$`min [m]`) %>% range(na.rm = TRUE)

  ui = tagList(
    navbarPage(
      # theme = "cerulean",  # <--- To use a theme, uncomment this
      "",
      tabPanel("Awesome Geodata Table",
               sidebarPanel(
                 awesometableFilterUI("awesome_geodata_table", spatial_res_range),
                 width = 3
               ),
               mainPanel(
                 awesometableOutputUI("awesome_geodata_table"),
                 width = 9
               )
      ),
      tabPanel("Add a Dataset", "Content to come")
    )
  )

  server <- function(input, output, session) {
    awesometableServer("awesome_geodata_table")
  }

  shinyApp(ui, server)
}

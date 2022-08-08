library(dplyr)
library(purrr)
library(lubridate)
library(googlesheets4)
library(stringr)
library(shiny)
library(shinyjs)
library(shinythemes)
library(shinyWidgets)
library(reactable)
library(reactablefmtr)
library(katexR)

# data("COLUMN_CATEGORIES_TEMPRES")

list.files("R", full.names = TRUE) %>%
  discard(str_detect, "app.R") %>%
  map(source)

table_raw <- agt_raw_read()
column_types <- get_column_types(table_raw)
double_column_names <- get_double_column_names(table_raw)
table_data <- table_raw %>%
  agt_table() %>%
  agt_prepare(column_types)
table_config <- agt_configure(table_data, double_column_names, column_types)
spatial_res_range <- c(table_data$`min [m]`, table_data$`max [m]`) %>%
  range(na.rm = TRUE)
temporal_cov_range <- c(table_data$start, table_data$end) %>%
  range(na.rm = TRUE) %>%
  year()
temporal_res_unique <- COLUMN_CATEGORIES_TEMPRES %>% discard(str_detect, "static")


awesome_geodata_table_App <- function() {


  ui = tagList(
    navbarPage(
      # theme = "cerulean",  # <--- To use a theme, uncomment this
      "",
      tabPanel("Awesome Geodata Table",
               sidebarPanel(
                 awesometableFilterUI(
                   "awesome_geodata_table"
                 ),
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

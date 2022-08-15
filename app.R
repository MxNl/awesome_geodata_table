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

# awesome_geodata_table_App <- function() {

table_raw <- agt_raw_read()
column_types <- get_column_types(table_raw)
double_column_names <- get_double_column_names(table_raw)
table_data <<- table_raw %>%
  agt_table() %>%
  agt_prepare(column_types)
table_config <<- agt_configure(table_data, double_column_names, column_types)
spatial_res_range <- c(table_data$`min [m]`, table_data$`max [m]`) %>%
  range(na.rm = TRUE)
temporal_cov_range <- c(table_data$start, table_data$end) %>%
  range(na.rm = TRUE) %>%
  year()
temporal_res_unique <- COLUMN_CATEGORIES_TEMPRES %>% discard(str_detect, "static")

ui = tagList(
  header = tags$img(src = 'image_w_logo_300dpi.png', width = '100%'),
  # tags$head(
  #   tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap_custom.css")
  # ),
  fluidPage(
    includeCSS("www/agt_style.css"),
    navbarPage(
      # theme = "agt_style.css",  # <--- To use a theme, uncomment this
      "",
      tabPanel("Search the Awesome Geodata Table",
               fluidRow(
                 column(
                   width = 10,
                   offset = 1,
                   h2("Welcome to the AwesomeGeodataTable!"),
                   p("Here you can search for data that represents spatially
                 continuous data describing predominantly geophysical or environmental properties.
                 This data collection focusses on the application of
                 spatial predictor variables in machine learning tasks"),
                   p("The completeness of this collection of datasets is still growing.
                 Therefore, any contribution of new datasets is very welcome.
                 To add a dataset of which you think it might be helpful,
                 please click on the tab 'Add a Dataset'."),
                   p("Use the following filters to define your search
                 for parameters or datasets.")
                 ),
                 style = "padding-bottom:20px"
               ),
               hr(),
               fluidRow(
                 width = 3,
                 style = "padding-bottom:20px; padding-top:20px",
                 awesometableFilterUI(
                   "awesome_geodata_table",
                   table_data,
                   spatial_res_range,
                   temporal_cov_range,
                   temporal_res_unique
                 ),
               ),
               hr(),
               fluidRow(
                 style = "padding-top:20px",
                 column(
                   width = 10,
                   offset = 1,
                   awesometableOutputUI("awesome_geodata_table")
                 )
               )
      ),
      tabPanel("Add a Dataset", "Content to come")
    ))
)

server <- function(input, output, session) {
  awesometableServer("awesome_geodata_table", table_data)
}

shinyApp(ui, server)
# }

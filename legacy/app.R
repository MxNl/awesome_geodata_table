library(dplyr)
library(purrr)
library(tidyr)
library(lubridate)
library(googlesheets4)
library(stringr)
library(shinycssloaders)
library(shiny)
library(shinyjs)
library(shinythemes)
library(shinyalert)
library(shinyFeedback)
library(shinyWidgets)
library(shinyvalidate)
library(shinydashboard)
library(shinyBS)
library(reactable)
library(reactablefmtr)
library(katexR)
library(tippy)


data("INPUT_CHOICES_TEMPRES")
data("column_categories_domain")
data("temporal_coverage_startvalues")
data("INPUT_CHOICES_VERSIONUPDATES")
data("INPUT_CHOICES_TEMPORALTYPE")
data("INPUT_CHOICES_COORDREFSYS")
data("COLUMNS_TOGGLE_INVISIBLE")

# awesome_geodata_table_App <- function() {

gs4_auth(cache = ".secrets", email = TRUE)

table_raw <- agt_raw_read()
column_types <- get_column_types(table_raw)
double_column_names <- get_double_column_names(table_raw)
table_data <<- table_raw %>%
  agt_table() %>%
  agt_prepare(column_types)
table_config <<- agt_configure(table_data, double_column_names, column_types)
filter_specs <- generate_filter_specs(table_data)
input_choices <- generate_input_choices(table_data)
slider_ids <- 1:3
# Custom colour ramp

ui = tagList(
  header = tags$img(src = 'image_w_logo_300dpi.png', width = '100%'),
  fluidPage(
    # tags$head(tags$script(type="text/javascript", src = "navbar_link_icon.js")),
    tags$style("@import url(https://use.fontawesome.com/releases/v5.7.2/css/all.css);"),
    includeCSS("www/agt_style.css"),
    setSliderColor(rep_len("#EC8791",   length(slider_ids)), slider_ids),
    navbarPage(
      # theme = "agt_style.css",  # <--- To use a theme, uncomment this
      "",
      tabPanel(
        "Search the Awesome Geodata Table",
        icon = icon("search"),
        fluidRow(
          column(
            width = 10,
            offset = 1,
            h1("Welcome to the AwesomeGeodataTable!"),
            br(),
            p("Here you can search for data that represents spatially
                 continuous data describing predominantly geophysical or environmental properties.
                 This data collection focusses on the application of
                 spatial predictor variables in machine learning tasks"),
            p("The completeness of this collection of datasets is still growing.
                 Therefore, any contribution of new datasets is very welcome.
                 To add a dataset of which you think it might be helpful,
                 please click on the tab 'Add a Dataset'"
              # shinyLink("adddataset", "'Add a Dataset'")
            ),
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
            filter_specs
          ),
        ),
        hr(),
        fluidRow(
          style = "padding-top:20px;padding-bottom:50px",
          awesometableOutputUI("awesome_geodata_table")
        ),
      ),
      tabPanel(
        "Add a Dataset",
        value = "adddataset",
        icon = icon("plus"),
        adddatasetUI(
          "adddataset",
          input_choices
        )
      ),
      tabPanel(
        "Info",
        icon = icon("info-circle"),
        infotUI("info")
      )
    )
  )
)

server <- function(input, output, session) {
  awesometableServer("awesome_geodata_table", table_data)
  adddatasetServer("adddataset", table_data, input_choices)
}

shinyApp(ui, server)
# }

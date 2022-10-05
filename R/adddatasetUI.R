adddatasetUI <- function(id, input_choices) {
  tagList(
    fluidRow(
      column(
        width = 6,
        offset = 3,
        style = "padding-bottom: 50px",
        shinyFeedback::useShinyFeedback(),
        textInput(
          NS(id, "Dataset"),
          "Dateset name",
          value = "",
          placeholder = "Please type in the dataset name",
          width = "100%"
        ),

        selectizeInput(
          NS(id, "Parameter"),
          "Parameter",
          choices = input_choices$input_choices_parameter,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please choose a parameter or type in a new parameter name",
            maxItems = 1
          )
        ),
        # textOutput(NS(id, "parameter_fb")),

        selectizeInput(
          NS(id, "Tags"),
          "Tags",
          choices = input_choices$input_choices_tags,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please choose at least one tag and/or type in a new tag"
          )
        ),

        selectizeInput(
          NS(id, "Domain"),
          label = "Domain",
          choices = column_categories_domain,
          selected = character(0),
          multiple = TRUE,
          options = list(
            placeholder = "Please choose a domain",
            maxItems = 1
          ),
          width = "100%"
        ),

        selectizeInput(
          NS(id, "Unit"),
          "Unit",
          choices = input_choices$input_choices_unit,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please choose a unit or type in a new unit in latex equation syntax",
            maxItems = 1
          )
        ),

        selectizeInput(
          NS(id, "min"),
          "Minimum (shortest) temporal resolution",
          choices = input_choices$input_choices_tempres,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            placeholder = "Please choose a temporal resolution",
            maxItems = 1
          )
        ),

        selectizeInput(
          NS(id, "max"),
          "Maximum (longest) temporal resolution",
          choices = input_choices$input_choices_tempres,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            placeholder = "Please choose a temporal resolution",
            maxItems = 1
          )
        ),

        selectizeInput(
          NS(id, "min [m]"),
          "Minimum (smallest) spatial resolution",
          choices = input_choices$input_choices_spatialmin,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please type in a spatial resolution in m",
            maxItems = 1
          )
        ),

        selectizeInput(
          NS(id, "max [m]"),
          "Maximum (greatest) spatial resolution",
          choices = input_choices$input_choices_spatialmax,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please type in a spatial resolution in m",
            maxItems = 1
          )
        ),

        selectizeInput(
          NS(id, "vertical"),
          "Vertical spatial resolution",
          choices = input_choices$input_choices_spatialvertical,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = FALSE,
            placeholder = "Please choose a vertical spatial resolution",
            maxItems = 1
          )
        ),

        tags$b("Temporal coverage"),
        br(),
        tags$i("Hints:"),
        tags$i(
          tags$ul(
            tags$li("Leave both inputs fields empty, if the parameter is time-invariant/static"),
            tags$li("Leave the right input field empty, if the temporal coverage is regularly extended to the present")
          )
        ),
        dateRangeInput(
          NS(id, "start_end"),
          NULL,
          start = "",
          end = "",
          width = "100%",
          format = "yyyy/mm/dd",
          startview = "year"
        )

      ),
      fluidRow(
        column(
          width = 6,
          offset = 3,
          style = "padding-bottom: 100px",
          align = "center",
          # setShadow("button_send"),
          actionButton(
            NS(id, "button_send"),
            "Add entry",
            width = "50%",
            icon = icon("paper-plane"),
            style = "background-color: #FCD8A5;"
          )
        )
      ),
      fluidRow(
        tableOutput(NS(id, "input_values"))
      )
    )
  )
}
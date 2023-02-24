adddatasetUI <- function(id, input_choices) {
  tagList(
    fluidRow(
      column(
        width = 6,
        offset = 3,
        style = "padding-bottom: 100px",
        align = "left",
        # setShadow("button_send"),
        br(),
        br(),
        HTML("To add a new dataset to the <span style='font-family: Rubik Dirt; font-size:
          20px'>AwesomeGeodataTable</span> please fill out the following input fields with the related meta data."
        ),
        HTML("<p><span style='font-weight:bold'>Hints</span></p>"),
        tags$ul(
          tags$li("Required input fields are marked with an asterics (*)"),
          tags$li("Fur further information about each input field, please just hover over the input field"),
          tags$li("To finally add your dataset, click on the 'Add entry' button at the bottom")
        )
      )
    ),
    fluidRow(
      column(
        width = 6,
        offset = 3,
        style = "padding-bottom: 50px; .popover{
            max-width: 100%;
          }",
        shinyFeedback::useShinyFeedback(),
        popify(
          textInput(
            NS(id, "Dataset"),
            "Dataset name*",
            value = "",
            placeholder = "Please type in the dataset name",
            width = "100%"
          ),
          "Input help",
          "<ul><li>Please enter the name of the dataset using the original spelling that has been used for example in the related publication or a project website</li></ul>",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        selectizeInput(
          NS(id, "Parameter"),
          "Parameter*",
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

        selectizeInput(
          NS(id, "Tags"),
          "Tags*",
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
          label = "Domain*",
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
          "Unit*",
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

        h3("Resolution"),

        selectizeInput(
          NS(id, "min"),
          "Minimum (shortest) temporal resolution*",
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
          "Maximum (longest) temporal resolution*",
          choices = input_choices$input_choices_tempres,
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            placeholder = "Please choose a temporal resolution",
            maxItems = 1
          )
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "upload_delay"),
            label = "Upload delay",
            choices = input_choices$input_choices_uploaddelay,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a time period from the list or enter a new one",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Here you can enter a value for a <b>time period</b>. This period should indicate the temporal delay between data acquisition and publishing. This is important to know <b>how recent</b> the data might be!</li><li>Periods should be abbreviated according to this convention:<ul><li> 1 second = 1 s</li><li> 2 minutes = 2 min</li><li> 1 hour = 1 h</li><li> 1 day = 1 d</li><li> 2 month = 2 mo</li><li> 1 year = 1 yr</li></li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
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

        h3("Coverage"),

        # tags$b("Temporal coverage*"),
        # br(),
        # tags$i("Hints:"),
        # tags$i(
        #   tags$ul(
        #     tags$li("Leave both inputs fields empty, if the parameter is time-invariant/static"),
        #     tags$li("Leave the right input field empty, if the temporal coverage is regularly extended to the present")
        #   )
        # ),
        popify(
          dateRangeInput(
            NS(id, "start_end"),
            "Temporal coverage*",
            start = "",
            end = "",
            width = "100%",
            format = "yyyy/mm/dd",
            startview = "year"
          ),
          "Input help",
          "<ul><li>Leave <b>both</b> inputs fields empty, if the parameter is time-invariant/static</li><li>Leave the <b>right</b> input field empty, if the temporal coverage is regularly extended to the present</li></ul> ",
          placement = "left",
          trigger = "hover",
        ),

        popify(
          selectizeInput(
            NS(id, "temporal_type"),
            "Temporal type",
            choices = input_choices$input_choices_temporaltype,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = FALSE,
              placeholder = "Please choose a temporal type from the list",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            NS(id, "spatial_coverage"),
            "Spatial coverage*",
            choices = input_choices$input_choices_spatialcoverage,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a tag for a spatial coverage or type in a new tag",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),


        h3("Data structure"),

        popify(
          selectizeInput(
            NS(id, "type"),
            "Data type*",
            choices = input_choices$input_choices_type,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = FALSE,
              placeholder = "Please choose a data type from the list",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            NS(id, "format"),
            "Data format",
            choices = input_choices$input_choices_format,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a data format from the list or type in a new format",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            NS(id, "file_extension"),
            "File extension",
            choices = input_choices$input_choices_fileextension,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a file extension from the list or type in a new file extension",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),


        # h3("Coordinate Reference System (CRS)"),

        popify(
          selectizeInput(
            NS(id, "coord_refsys"),
            "Coordinate Reference System (CRS)",
            choices = NULL,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a CRS from the list or type in a new CRS",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        h3("References"),

        popify(
          selectizeInput(
            inputId = NS(id, "publisher"),
            label = "Publisher",
            choices = input_choices$input_choices_publisher,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a publisher from the list or create a new entry",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "Published_first"),
            label = "Published first",
            choices = rev(1980:as.numeric(format(Sys.Date(), "%Y"))),
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = FALSE,
              placeholder = "Please choose a year",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          textInput(
            NS(id, "Literature"),
            "Literature",
            value = "",
            placeholder = "Please type in a URL of the location of related literature",
            width = "100%"
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "Version_updates"),
            label = "Version Updates",
            choices = input_choices$input_choices_versionupdates,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = FALSE,
              placeholder = "Please choose an option",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Have there been <b>updates of the dataset version</b> in the past or are there updates planned?</li><li>In this context version updates refers to updates of the methods used to generate the dataset.</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),


        h3("Access and Usage"),

        popify(
          textInput(
            NS(id, "Download"),
            "Download",
            value = "",
            placeholder = "Please type in a URL of the location for downloading the dataset",
            width = "100%"
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "access"),
            label = "Access",
            choices = input_choices$input_choices_access,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose an access from the list or create a new entry",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "license"),
            label = "License",
            choices = input_choices$input_choices_license,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a license from the list or create a new entry",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          textInput(
            NS(id, "data_limitations"),
            "Data limitations",
            value = "",
            placeholder = "Please type in a note about known limitations of the dataset",
            width = "100%"
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "Mmethod"),
            label = "Method",
            choices = input_choices$input_choices_method,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose a method from the list or create a new entry",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Text <b>here</b>!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
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
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
          tags$li(HTML("Required input fields are annotated with the note <span style='color:#A94442'>Required</span>
 when unfilled")),
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
            NS(id, "Dataset name"),
            "Dataset name",
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

        h3("Resolution"),

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

        popify(
          selectizeInput(
            inputId = NS(id, "Upload delay"),
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
          "<ul><li>Here you can enter a value for a <b>time period</b>. This period should indicate the temporal delay between data acquisition and publishing. This important to know <b>how recent</b> the data might be!</li><li>Periods should be abbreviated according to this convention:<ul><li> 1 second = 1 s</li><li> 2 minutes = 2 min</li><li> 1 hour = 1 h</li><li> 1 day = 1 d</li><li> 2 month = 2 mo</li><li> 1 year = 1 yr</li></li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          numericInput(
            NS(id, "min [m]"),
            "Minimum (smallest) spatial resolution",
            # choices = input_choices$input_choices_spatialmin,
            # selected = character(0),
            # multiple = TRUE,
            value = NULL,
            width = "100%",
            min = 0,
            # options = list(
            # create = TRUE,
            # placeholder = "Please type in a spatial resolution in m"
            # maxItems = 1
            # )
          ),
          "Input help",
          "<ul><li>Here you must enter a numeric value for the <b>minimum spatial resolution</b> in meters of the dataset. For some datasets the minimum and maximum spatial resolution might be the same, if it is based on a regular grid with a projected reference system</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          numericInput(
            NS(id, "max [m]"),
            "Maximum (greatest) spatial resolution",
            # choices = input_choices$input_choices_spatialmin,
            # selected = character(0),
            # multiple = TRUE,
            value = NULL,
            width = "100%",
            min = 0,
            # options = list(
            # create = TRUE,
            # placeholder = "Please type in a spatial resolution in m"
            # maxItems = 1
            # )
          ),
          "Input help",
          "<ul><li>Here you must enter a numeric value for the <b>maximum spatial resolution</b> in meters of the dataset. For some datasets the minimum and maximum spatial resolution might be the same, if it is based on a regular grid with a projected reference system</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
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

        # tags$b("Temporal coverage"),
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
            "Temporal coverage",
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
            NS(id, "Temporal type"),
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
          "<ul><li>Here you can choose one of the pre-defined values for <b>Temporal type</b>!</li><ul><li>Choose <b>dynamic</b> if the dataset is a time series, e.g. hourly precipitation</li><li>Choose <b>aggregated-dynamic</b> if the dataset represents long-term aggregates of a time series, e.g. long-term monthly maximum temperature</li><li>Choose <b>semi-static</b> if the dataset represents a 'snapshot' of a variable that changes within a period of multiple years to decades, e.g. land-use</li><li>Choose <b>static</b> if the dataset represents a variable that doesn't change within human scale periods, e.g. geological properties</li></ul></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            NS(id, "Coverage (spatial)"),
            "Spatial coverage",
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
            "Data type",
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
            NS(id, "file extension"),
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
            NS(id, "Coordinate reference system"),
            "Coordinate Reference System (CRS)",
            choices = input_choices$input_choices_coordrefsys,
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
          "<ul><li>Here you can provide information about the <b>Coordinate reference system</b> of the dataset</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        h3("References"),

        popify(
          selectizeInput(
            inputId = NS(id, "Publisher"),
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
          "<ul><li>Here you can provide information on the dataset <b>publisher</b>!</li><li>This can be an governmental authority, a research institute, the affiliation of the first author or just the first authors name</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "Published first"),
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
          "<ul><li>Here you can provide a year in which the dataset was <b>published</b> for the <b>first</b> time!</li><li>If a dataset has multiple versions, this year may relate to the first version or to the version that you are currently adding here now!</li></ul> ",
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
          "<ul><li>Here you can provide an URL that links to a related scientific article, data desciptor, documentation!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "Version updates"),
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
          "<ul><li>Here you can provide an URL that points to a location where the dataset can be <b>Download</b>ed!</li><li>This can be a data repository, a project website, an online portal or a documentation if multiple download options are available</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "Access"),
            label = "Access",
            choices = input_choices$input_choices_access,
            selected = character(0),
            multiple = TRUE,
            width = "100%",
            options = list(
              create = TRUE,
              placeholder = "Please choose an access type from the list or create a new entry",
              maxItems = 1
            )
          ),
          "Input help",
          "<ul><li>Here you can provide an <b>Access</b> type!</li><li>This should point out the requirements in order to be able to download the dataset.</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "License"),
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
          "<ul><li>Here you can provide information on the <b>License</b> under which the dataset was published!</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          textInput(
            NS(id, "Data limitations"),
            "Data limitations",
            value = "",
            placeholder = "Please type in a note about known limitations of the dataset",
            width = "100%"
          ),
          "Input help",
          "<ul><li>Here you can provide information on <b>Data limitations</b> when using the dataset, e.g. high uncertainty in some regions</li></ul> ",
          placement = "left",
          trigger = "hover",
          options = list(container = "body")
        ),

        popify(
          selectizeInput(
            inputId = NS(id, "Method"),
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
          "<ul><li>Here you can provide information on the <b>Method</b>s used to generate the dataset, e.g. interpolation between station data!</li></ul> ",
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
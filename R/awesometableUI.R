awesometableFilterUI <- function(id, filter_specs) {
  tagList(
    column(
      width = 3,
      offset = 1,
      selectizeInput(
        NS(id, "Dataset name"),
        label = "Dataset name",
        choices = filter_specs$filter_choices_datasetname,
        multiple = TRUE,
        width = "100%"
      ),
      selectizeInput(
        NS(id, "Parameter"),
        label = "Parameter",
        choices = filter_specs$filter_choices_parameter,
        multiple = TRUE,
        width = "100%"
      ),
      selectizeInput(
        NS(id, "Tags"),
        label = "Tags",
        choices = filter_specs$filter_choices_tags,
        multiple = TRUE,
        width = "100%"
      )
    ),
    column(
      width = 3,
      selectizeInput(
        NS(id, "Domain"),
        label = "Domain",
        choices = filter_specs$filter_choices_domain,
        multiple = TRUE,
        width = "100%"
      ),
      selectizeInput(
        NS(id, "spatial_coverage"),
        label = "Coverage (spatial)",
        choices = filter_specs$filter_choices_spatcov,
        multiple = TRUE,
        width = "100%"
      )
    ),
    column(
      width = 4,
      offset = 0,
      fluidRow(
        column(
          width = 10,
          sliderInput(
            NS(id, "spatial_res"),
            label = "Lowest acceptable spatial resolution",
            min = 0,
            max = last(filter_specs$spatial_res_range),
            value = last(filter_specs$spatial_res_range),
            step = 10,
            post = " m",
            width = "100%"
          ),
          sliderTextInput(
            NS(id, "temporal_res"),
            label = "Lowest acceptable temporal resolution",
            choices = filter_specs$temporal_res_unique,
            selected = last(filter_specs$temporal_res_unique),
            grid = TRUE,
            width = "100%"
          )
        ),
        column(
          width = 2,
          br(),
          autonumericInput(
            NS(id, "spatial_res_num"),
            "",
            minimumValue = 0,
            maximumValue = last(filter_specs$spatial_res_range),
            value = last(filter_specs$spatial_res_range),
            currencySymbol = " m",
            currencySymbolPlacement = "s",
            allowDecimalPadding = FALSE,
            decimalPlaces = 1
          ),
          br(),
          br(),
          selectizeInput(
            NS(id, "temporal_res_num"),
            label = "",
            choices = filter_specs$temporal_res_unique,
            selected = last(filter_specs$temporal_res_unique),
            multiple = FALSE,
            width = "100%"
          )
        )
      ),
      sliderInput(
        NS(id, "temporal_coverage"),
        label = "Coverage (temporal)",
        min = filter_specs$temporal_cov_range[1],
        max = filter_specs$temporal_cov_range[2],
        value = temporal_coverage_startvalues,
        sep = "",
        width = "100%"
      )
    ),
    fluidRow(
      column(
        width = 3,
        offset = 4,
        actionButton(
          NS(id, "button_filter"),
          HTML("<b>Apply filters</b>"),
          width = "100%",
          icon = icon("search"),
          style = "background-color: #EC8791;"
        )
      )
    )
  )
}

awesometableOutputUI <- function(id) {
  tagList(
    column(
      width = 10,
      offset = 1,
      reactableOutput(NS(id, "table")) %>%
        withSpinner()
    ),
    column(
      width = 1,
      # h3("Number of parameters found"),
      fluidRow(
        style = "padding-bottom:10px; padding-left:14px",
        downloadButton(NS(id, "download_data"))
      ),
      fluidRow(valueBoxOutput(NS(id, "n_search_results"))),
      fluidRow(valueBoxOutput(NS(id, "n_search_datasets")))
    )
  )
}
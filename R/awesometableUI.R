awesometableFilterUI <- function(id, table_data, spatial_res_range, temporal_cov_range, temporal_res_unique) {
  tagList(
    column(
      width = 3,
      offset = 1,
      selectizeInput(
        NS(id, "Dataset name"),
        label = "Dataset name",
        choices = unique(table_data$`Dataset name`) %>% sort(),
        multiple = TRUE,
        width = "100%"
      ),
      selectizeInput(
        NS(id, "Parameter"),
        label = "Parameter",
        choices = unique(table_data$Parameter) %>% sort(),
        multiple = TRUE,
        width = "100%"
      ),
      selectizeInput(
        NS(id, "Tags"),
        label = "Tags",
        choices = unique(table_data$Tags) %>%
          stringr::str_c(collapse = ",") %>%
          stringr::str_split(pattern = ",") %>%
          unlist() %>%
          unique() %>%
          sort(),
        multiple = TRUE,
        width = "100%"
      )
    ),
    column(
      width = 3,
      selectizeInput(
        NS(id, "Domain"),
        label = "Domain",
        choices = unique(table_data$Domain) %>% sort(),
        multiple = TRUE,
        width = "100%"
      ),
      selectizeInput(
        NS(id, "spatial_coverage"),
        label = "Coverage (spatial)",
        choices = unique(table_data$`Coverage (spatial)`) %>% sort(),
        multiple = TRUE,
        width = "100%"
      )
    ),
    column(
      width = 4,
      offset = 0,
      sliderInput(
        NS(id, "spatial_res"),
        label = "Resolution (spatial)",
        min = 0,
        max = spatial_res_range[2],
        value = spatial_res_range,
        width = "100%"
      ),
      sliderTextInput(
        NS(id, "temporal_res"),
        label = "Resolution (temporal)",
        choices = temporal_res_unique,
        selected = c(temporal_res_unique[1], temporal_res_unique[length(temporal_res_unique)]),
        grid = TRUE,
        width = "100%"
      ),
      sliderInput(
        NS(id, "temporal_coverage"),
        label = "Coverage (temporal)",
        min = temporal_cov_range[1],
        max = temporal_cov_range[2],
        value = TEMPORAL_COVERAGE_STARTVALUES,
        sep = "",
        width = "100%"
      )
    )
  )
}

awesometableOutputUI <- function(id) {
  tagList(
    column(
      width = 10,
      offset = 1,
      reactableOutput(NS(id, "table"))
    ),
    column(
      width = 1,
      # h3("Number of parameters found"),
      fluidRow(
        style = "padding-bottom:10px",
        downloadButton(NS(id, "download_data"))
      ),
      fluidRow(valueBoxOutput(NS(id, "n_search_results"))),
      fluidRow(valueBoxOutput(NS(id, "n_search_datasets")))
    )
  )
}
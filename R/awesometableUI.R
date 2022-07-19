awesometableFilterUI <- function(id) {
  tagList(
    selectInput(
      NS(id, "Dataset name"),
      label = "Dataset name",
      choices = unique(table_data$`Dataset name`) %>% sort(),
      multiple = TRUE
    ),
    selectInput(
      NS(id, "Parameter"),
      label = "Parameter",
      choices = unique(table_data$Parameter) %>% sort(),
      multiple = TRUE
    ),
    selectInput(
      NS(id, "Tags"),
      label = "Tags",
      choices = unique(table_data$Tags) %>%
        stringr::str_c(collapse = ",") %>%
        stringr::str_split(pattern = ",") %>%
        unlist() %>%
        unique() %>%
        sort(),
      multiple = TRUE
    ),
    selectInput(
      NS(id, "Domain"),
      label = "Domain",
      choices = unique(table_data$Domain) %>% sort(),
      multiple = TRUE
    ),
    sliderInput(
      NS(id, "spatial_res"),
      label = "Resolution (spatial)",
      min = 0,
      max = spatial_res_range[2],
      value = spatial_res_range
    ),
    sliderTextInput(
      NS(id, "temporal_res"),
      label = "Resolution (temporal)",
      choices = temporal_res_unique,
      selected = c(temporal_res_unique[1], temporal_res_unique[length(temporal_res_unique)]),
      grid = TRUE
    ),
    sliderInput(
      NS(id, "temporal_coverage"),
      label = "Coverage (temporal)",
      min = temporal_cov_range[1],
      max = temporal_cov_range[2],
      value = temporal_cov_range,
      sep = ""
    ),
    selectInput(
      NS(id, "spatial_coverage"),
      label = "Coverage (spatial)",
      choices = unique(table_data$`Coverage (spatial)`) %>% sort(),
      multiple = TRUE
    )
  )
}

awesometableOutputUI <- function(id) {
  reactableOutput(NS(id, "table"))
}
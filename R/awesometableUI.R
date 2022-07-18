awesometableFilterUI <- function(id, spatial_res_range, temporal_res_unique, temporal_cov_range) {
  tagList(
    selectInput(
      NS(id, "Dataset name"),
      label = "Dataset name",
      choices = unique(data$`Dataset name`) %>% sort(),
      multiple = TRUE
    ),
    selectInput(
      NS(id, "Parameter"),
      label = "Parameter",
      choices = unique(data$Parameter) %>% sort(),
      multiple = TRUE
    ),
    selectInput(
      NS(id, "Tags"),
      label = "Tags",
      choices = unique(data$Tags) %>%
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
      choices = unique(data$Domain) %>% sort(),
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
      choices = unique(data$`Coverage (spatial)`) %>% sort(),
      multiple = TRUE
    )
  )
}

awesometableOutputUI <- function(id) {
  reactableOutput(NS(id, "table"))
}
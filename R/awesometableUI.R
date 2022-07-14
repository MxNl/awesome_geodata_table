awesometableFilterUI <- function(id, spatial_res_range) {
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
      label = "spatial Resolution",
      min = spatial_res_range[1],
      max = spatial_res_range[2],
      value = spatial_res_range
    )
  )
}

awesometableOutputUI <- function(id) {
  reactableOutput(NS(id, "table"))
}
awesometableFilterUI <- function(id) {
  tagList(
    selectInput(
      NS(id, "Dataset name"),
      label = "Dataset name",
      choices = unique(data$`Dataset name`),
      multiple = TRUE
    ),
    selectInput(
      NS(id, "Parameter"),
      label = "Parameter",
      choices = unique(data$Parameter),
      multiple = TRUE
    )
  )
}

awesometableOutputUI <- function(id) {
  reactableOutput(NS(id, "table"))
}
#' generate html table
#'
#' @param table_data a tibble.
#' @return The html table.
#' @export

agt_html <- function() {
  table_data %>%
    reactable::reactable(
      columnGroups = table_config$header_sketch[[2]],
      # searchable = TRUE,
      # theme = nytimes(),
      pagination = FALSE,
      defaultSorted = c("Dataset name", "Parameter"),
      # groupBy = "Dataset name",
      defaultExpanded = TRUE,
      striped = TRUE,
      # bordered = TRUE,
      height = 800,
      highlight = TRUE,
      compact = TRUE,
      defaultColDef = colDef(
        align = "center",
        vAlign = "center",
        minWidth = 110,
        headerVAlign = "center",
        headerStyle = list(font_size = 16)
      ),
      columns = columndef_list(),
      # details = function(index) paste("Details for row:", index)
    )
}

awesome_geodata_table_html <- function(x) {
  DT::datatable(x,
    filter = "top",
    options = list(
      pageLength = 5,
      # autoWidth = TRUE,
      width = '100%',
      scrollX = TRUE,
      # scrollY = TRUE,
      paging = FALSE,
      scrollY = '50vh',
      scrollCollapse = TRUE
    )
  ) |>
    DT::formatStyle(columns = 1:ncol(x), fontSize = '90%')
}

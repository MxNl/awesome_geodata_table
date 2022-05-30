awesome_geodata_table_html <- function(x) {
  DT::datatable(x,
                filter = 'top',
                options = list(
    pageLength = 5, autoWidth = TRUE
  ))
}

#' generate html table
#'
#' @param table_data a tibble.
#' @return The html table.
#' @export

awesome_geodata_table_html <- function(table_data) {
  header_sketch <- complex_header(CSV_TABLE_PATH)

  headers_multi_level <- header_sketch |>
    unique_headers_clean(as_character_vector = TRUE)

  show_main <- which(headers_multi_level %in% c(
    "Parameter",
    "Dataset name",
    "Tags",
    "Domain",
    "Resolution-temporal-min",
    "Resolution-temporal-max",
    "Resolution-spatial-min_[m]",
    "Resolution-spatial-max_[m]",
    "Coverage-temporal-start",
    "Coverage-temporal-end",
    "Coverage-spatial-spatial",
    "Data_type",
    "Data_format"
  ))

  hide_main <- which(headers_multi_level %in% headers_multi_level[-show_main])

  column_definintion <- table_data %>%
    columndef_list()

  table_data_prepared <- table_data |>
    # format_tags not causing line breaks yet.
    format_utf8_critical_characters() |>
    # format_link() |>
    format_tags() |>
    # format_colwidth_workaround() |>
    format_lower_case() |>
    # format_resolution() |>
    format_comment() |>
    format_equations() %>%
    impute_tags()

  table_reactable <- table_data_prepared %>%
    reactable::reactable(
      columnGroups = header_sketch[[2]],
      searchable = TRUE,
      filterable = TRUE,
      defaultSorted = c("Dataset name", "Parameter"),
      groupBy = "Dataset name",
      defaultExpanded = TRUE,
      striped = TRUE,
      # bordered = TRUE,
      height = 1000,
      highlight = TRUE,
      compact = TRUE,
      elementId = "awesome_geodata_table_download",
      defaultColDef = colDef(
        align = "center"
      ),
      columns = column_definintion
    )

  htmltools::browsable(
    htmltools::tagList(
      my_csv2_download,
      htmltools::tags$button(
        htmltools::tagList("Download as CSV"),
        onclick = "mydownloadDataCSV('awesome_geodata_table_download', 'awesome_geodata_table_download.csv')"
      ),
      table_reactable
    )
  )

  # DT::datatable(
  #   filter = "top",
  #   extensions = c("FixedColumns", "Buttons"),
  #   extensions = c("Buttons"),
  #   container = header_sketch[[2]],
  #   escape = FALSE,
  #   rownames = FALSE,
  #   options = list(
  #     pageLength = 5,
  #     width = "150%",
  #     autoWidth = TRUE,
  #     scrollX = TRUE,
  #     fixedColumns = list(leftColumns = 1),
  #     columnDefs = list(
  #       list(
  #         # width = '200px',
  #         targets = which(headers_multi_level %in% c("Comment", "Tags", "Name"))-1),
  #       list(
  #         targets = which(headers_multi_level %in% c("Comment", "Tags"))-1,
  #         render = DT::JS(
  #           "function(data, type, row, meta) {",
  #           "return type === 'display' && data.length > 30 ?",
  #           "'<span title=\"' + data + '\">' + data.substr(0, 30) + '...</span>' : data;",
  #           "}")
  #         )
  #       ),
  #     paging = FALSE,
  #     scrollY = "50vh",
  #     scrollCollapse = TRUE,
  #     # dom = "ft",
  #     search = list(search = ""),
  #     dom = "Bfrtip",
  #     buttons =
  #       list(
  #         list(
  #           extend = "collection",
  #           text = "Table Columns",
  #           buttons = list(
  #             list(
  #               extend = "colvisGroup",
  #               text = "Show all",
  #               show = ":hidden"
  #             ),
  #             list(
  #               extend = "colvisGroup",
  #               text = "Main Filter Columns",
  #               show = show_main,
  #               hide = hide_main
  #             )
  #           )
  #         ),
  #         # list(
  #         #   extend = 'collection',
  #         #   text = "Table control",
  #         #   buttons = list(
  #         #     text = "test",
  #         #     action = "function ( e, dt, node, config ) {
  #         #                 dt.column( -2 ).visible( ! dt.column( -2 ).visible() );
  #         #             }"
  #         #   )
  #         # ),
  #         "copy",
  #         "print",
  #         list(
  #           extend = "collection",
  #           buttons = c("csv", "excel", "pdf"),
  #           text = "Download"
  #         )
  #       )
  #   )
  # ) |>
  # DT::formatStyle(columns = 1:ncol(table_data), fontSize = "90%")
}

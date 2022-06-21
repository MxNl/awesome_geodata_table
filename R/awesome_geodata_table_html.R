awesome_geodata_table_html <- function(x) {
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
    "Extent-temporal-start",
    "Extent-temporal-end",
    "Extent-spatial-spatial",
    "Data_type",
    "Data_format"
  ))

  hide_main <- which(headers_multi_level %in% headers_multi_level[-show_main])

  x |>
    arrange(Parameter) |>
    # format_tags not causing line breaks yet.
    format_link() |>
    format_colwidth_workaround() |>
    format_tags() |>
    format_utf8_critical_characters() |>
    format_lower_case() |>
    # format_resolution() |>
    format_comment() |>
    DT::datatable(
      filter = "top",
      extensions = c("FixedColumns", "Buttons"),
      # extensions = c("Buttons"),
      container = header_sketch[[2]],
      escape = FALSE,
      rownames = FALSE,
      options = list(
        pageLength = 5,
        width = "150%",
        autoWidth = TRUE,
        scrollX = TRUE,
        fixedColumns = list(leftColumns = 1),
        columnDefs = list(
          list(
            # width = '200px',
            targets = which(headers_multi_level %in% c("Comment_Comment_Comment", "Tags_Tags_Tags", "Name_Name_Name"))-1),
          list(
            targets = which(headers_multi_level %in% c("Comment_Comment_Comment"))-1,
            render = JS(
              "function(data, type, row, meta) {",
              "return type === 'display' && data.length > 30 ?",
              "'<span title=\"' + data + '\">' + data.substr(0, 30) + '...</span>' : data;",
              "}")
            )
          ),
        paging = FALSE,
        scrollY = "50vh",
        scrollCollapse = TRUE,
        # dom = "ft",
        search = list(search = ""),
        dom = "Bfrtip",
        buttons =
          list(
            list(
              extend = "collection",
              text = "Table Columns",
              buttons = list(
                list(
                  extend = "colvisGroup",
                  text = "Show all",
                  show = ":hidden"
                ),
                list(
                  extend = "colvisGroup",
                  text = "Main Filter Columns",
                  show = show_main,
                  hide = hide_main
                )
              )
            ),
            # list(
            #   extend = 'collection',
            #   text = "Table control",
            #   buttons = list(
            #     text = "test",
            #     action = "function ( e, dt, node, config ) {
            #                 dt.column( -2 ).visible( ! dt.column( -2 ).visible() );
            #             }"
            #   )
            # ),
            "copy",
            "print",
            list(
              extend = "collection",
              buttons = c("csv", "excel", "pdf"),
              text = "Download"
            )
          )
      )
    ) |>
    DT::formatStyle(columns = 1:ncol(x), fontSize = "90%")
}

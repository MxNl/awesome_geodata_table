awesome_geodata_table_html <- function(x) {
  path <- here::here("inst", "extdata", "awesome_geodata_table.csv")

  headers <- readr::read_csv2(
    path,
    col_names = FALSE,
    n_max = 3
  ) |>
    tidyr::pivot_longer(everything()) |>
    mutate(name = stringr::str_remove(name, "X")) |>
    mutate(name = as.numeric(name)) |>
    arrange(name) |>
    group_by(name) |>
    mutate(rowspan = if_else(length(unique(value)) == 1, TRUE, FALSE)) |>
    mutate(
      colspan_group1 = if_else(length(unique(value)) > 1, first(value), NA_character_),
      colspan_group2 = if_else(length(unique(value)) > 1, nth(value, 2), NA_character_),
      colspan_group3 = if_else(length(unique(value)) > 1, last(value), NA_character_),
      rowspan2 = if_else(colspan_group2 == colspan_group3, TRUE, FALSE),
      rowspan2 = tidyr::replace_na(rowspan2, FALSE)
    ) |>
    group_by(colspan_group1) |>
    mutate(colspan_group1_n = n() / 3, .after = colspan_group1) |>
    group_by(colspan_group1, colspan_group2) |>
    mutate(colspan_group2_n = n() / 3, .after = colspan_group2) |>
    ungroup() |>
    mutate(style = if_else(rowspan == TRUE, stringr::str_glue("th(rowspan = 2, '{value}')"), NA_character_)) |>
    mutate(style = if_else(!is.na(colspan_group1), stringr::str_glue("th(colspan = {colspan_group1_n}, '{colspan_group1}')"), style))

  sketch_firstrow <- headers |>
    pull(style) |>
    unique() |>
    stringr::str_c(collapse = ", ") %>%
    stringr::str_c("tr(th(rowspan = 2, ''),", ., ")")
  # View()

  sketch_thirdrow <- headers |>
    filter(!is.na(colspan_group3)) |>
    distinct(name, colspan_group3) |>
    pull(colspan_group3)

  sketch_test <- htmltools::withTags(table(
    class = "display",
    thead(
      eval(parse(text = sketch_firstrow)),
      tr(
        lapply(sketch_thirdrow, th)
      )
    )
  ))
  sketch <- htmltools::withTags(table(
    class = "display",
    thead(
      tr(
        th(rowspan = 2, "Species"),
        th(colspan = 2, "Sepal"),
        th(colspan = 2, "Petal")
      ),
      tr(
        lapply(rep(c("Length", "Width"), 2), th)
      )
    )
  ))

  x |>
    # mutate(across(contains(" link"), ~ stringr::str_c("[link](", .x, ")"))) |>
    # mutate(across(contains(" link"), ~ stringr::str_c("<a href='", .x, "'link</a>"))) |>
    mutate(across(contains(" link"), ~ stringr::str_c("<a href='",.x,"'>","link","</a>"))) |>
    DT::datatable(
      filter = "top",
      extensions = c("FixedColumns", "Buttons"),
      container = sketch_test,
      escape = FALSE,
      # rownames = FALSE,
      options = list(
        pageLength = 5,
        width = "100%",
        autoWidth = TRUE,
        scrollX = TRUE,
        fixedColumns = list(leftColumns = 2),
        paging = FALSE,
        scrollY = "50vh",
        scrollCollapse = TRUE,
        # dom = "ft",
        search = list(search = ""),
        dom = 'Bfrtip',
        buttons =
          list('copy', 'print', list(
            extend = 'collection',
            buttons = c('csv', 'excel', 'pdf'),
            text = 'Download'
          ))
      )
    ) |>
    DT::formatStyle(columns = 1:ncol(x), fontSize = "90%")
}

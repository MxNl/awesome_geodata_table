complex_header <- function(filepath) {
  headers <- readr::read_csv2(
    here::here("inst", "extdata", "awesome_geodata_table.csv"),
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
      rowspan2 = if_else(colspan_group2 == colspan_group3 & value != colspan_group1, TRUE, FALSE),
      colspan_group3 = if_else(colspan_group2 == colspan_group3, NA_character_, colspan_group3),
      rowspan2 = tidyr::replace_na(rowspan2, FALSE)
    ) |>
    group_by(colspan_group1) |>
    mutate(colspan_group1_n = n() / 3, .after = colspan_group1) |>
    group_by(colspan_group1, colspan_group2) |>
    mutate(colspan_group2_n = n() / 3, .after = colspan_group2) |>
    ungroup() |>
    mutate(style1 = if_else(rowspan == TRUE, stringr::str_glue("th(rowspan = 3, '{value}')"), NA_character_)) |>
    mutate(style1 = if_else(!is.na(colspan_group1), stringr::str_glue("th(colspan = {colspan_group1_n}, '{colspan_group1}')"), style1)) |>
    mutate(style2 = if_else(rowspan2 == TRUE, stringr::str_glue("th(rowspan = 2, '{value}')"), NA_character_)) |>
    mutate(style2 = if_else(!is.na(colspan_group2) & colspan_group2_n != 1, stringr::str_glue("th(colspan = {colspan_group2_n}, '{colspan_group2}')"), style2))

  sketch_firstrow <- headers |>
    pull(style1) |>
    unique() |>
    stringr::str_c(collapse = ", ") %>%
    stringr::str_c("tr(", ., ")")
  # stringr::str_c("tr(th(rowspan = 2, ''),", ., ")")

  sketch_secondrow <- headers |>
    filter(!is.na(style2)) |>
    group_by(colspan_group1, colspan_group2) |>
    distinct(style2) |>
    pull(style2) |>
    stringr::str_c(collapse = ", ") %>%
    stringr::str_c("tr(", ., ")")

  sketch_thirdrow <- headers |>
    filter(!is.na(colspan_group3)) |>
    distinct(name, colspan_group3) |>
    pull(colspan_group3)

  sketch <- htmltools::withTags(table(
    class = "display",
    thead(
      eval(parse(text = sketch_firstrow)),
      eval(parse(text = sketch_secondrow)),
      tr(
        lapply(sketch_thirdrow, th)
      )
    )
  ))
  # sketch <- htmltools::withTags(table(
  #   class = "display",
  #   thead(
  #     tr(
  #       th(rowspan = 2, "Species"),
  #       th(colspan = 2, "Sepal"),
  #       th(colspan = 2, "Petal")
  #     ),
  #     tr(
  #       lapply(rep(c("Length", "Width"), 2), th)
  #     )
  #   )
  # ))

  return(list(headers, sketch))
}

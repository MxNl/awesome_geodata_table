complex_header <- function(filepath) {
  headers <- readr::read_csv2(
    filepath,
    col_names = FALSE,
    skip = 1,
    n_max = 3,
    show_col_types = FALSE,locale = readr::locale(decimal_mark = ",", grouping_mark = ".")
  ) |>
    tidyr::pivot_longer(dplyr::everything()) |>
    dplyr::mutate(name = stringr::str_remove(name, "X")) |>
    dplyr::mutate(name = as.numeric(name)) |>
    dplyr::arrange(name) |>
    dplyr::group_by(name) |>
    dplyr::mutate(rowspan = dplyr::if_else(length(unique(value)) == 1, TRUE, FALSE)) |>
    dplyr::mutate(
      colspan_group1 = dplyr::if_else(length(unique(value)) > 1, dplyr::first(value), NA_character_),
      colspan_group2 = dplyr::if_else(length(unique(value)) > 1, dplyr::nth(value, 2), NA_character_),
      colspan_group3 = dplyr::if_else(length(unique(value)) > 1, dplyr::last(value), NA_character_),
      rowspan2 = dplyr::if_else(colspan_group2 == colspan_group3 & value != colspan_group1, TRUE, FALSE),
      colspan_group3 = dplyr::if_else(colspan_group2 == colspan_group3, NA_character_, colspan_group3),
      rowspan2 = tidyr::replace_na(rowspan2, FALSE)
    ) |>
    dplyr::group_by(colspan_group1) |>
    dplyr::mutate(colspan_group1_n = dplyr::n() / 3, .after = colspan_group1) |>
    dplyr::group_by(colspan_group1, colspan_group2) |>
    dplyr::mutate(colspan_group2_n = dplyr::n() / 3, .after = colspan_group2) |>
    dplyr::ungroup() |>
    dplyr::mutate(style1 = dplyr::if_else(rowspan == TRUE, stringr::str_glue("th(rowspan = 3, '{value}')"), NA_character_)) |>
    dplyr::mutate(style1 = dplyr::if_else(!is.na(colspan_group1), stringr::str_glue("th(colspan = {colspan_group1_n}, '{colspan_group1}')"), style1)) |>
    dplyr::mutate(style2 = dplyr::if_else(rowspan2 == TRUE, stringr::str_glue("th(rowspan = 2, '{value}')"), NA_character_)) |>
    dplyr::mutate(style2 = dplyr::if_else(!is.na(colspan_group2) & colspan_group2_n != 1, stringr::str_glue("th(colspan = {colspan_group2_n}, '{colspan_group2}')"), style2))

  sketch_firstrow <- headers |>
    dplyr::pull(style1) |>
    unique() |>
    stringr::str_c(collapse = ", ") %>%
    stringr::str_c("tr(", ., ")")

  sketch_secondrow <- headers |>
    dplyr::filter(!is.na(style2)) |>
    dplyr::group_by(colspan_group1, colspan_group2) |>
    dplyr::distinct(style2) |>
    dplyr::pull(style2) |>
    stringr::str_c(collapse = ", ") %>%
    stringr::str_c("tr(", ., ")")

  sketch_thirdrow <- headers |>
    dplyr::filter(!is.na(colspan_group3)) |>
    dplyr::distinct(name, colspan_group3) |>
    dplyr::pull(colspan_group3)

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

  return(list(headers, sketch))
}

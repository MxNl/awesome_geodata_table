complex_header <- function(filepath) {
  headers <- readr::read_csv2(
    filepath,
    col_names = FALSE,
    skip = 1,
    n_max = 2,
    show_col_types = FALSE, locale = readr::locale(decimal_mark = ",", grouping_mark = ".")
  ) |>
    tidyr::pivot_longer(dplyr::everything()) |>
    dplyr::mutate(name = stringr::str_remove(name, "X")) |>
    dplyr::mutate(name = as.numeric(name)) |>
    dplyr::arrange(name)

  sketch <- headers|>
    dplyr::group_by(name) |>
      dplyr::filter(length(unique(value)) > 1) |>
    dplyr::mutate(
    columngroup_name = dplyr::if_else(length(unique(value)) > 1, dplyr::first(value), NA_character_),
    group_columns = dplyr::if_else(length(unique(value)) > 1, dplyr::last(value), NA_character_))|>
    dplyr::distinct(columngroup_name, group_columns) |>
    dplyr::group_by(columngroup_name) |>
    dplyr::group_split() |>
    purrr::map(~reactable::colGroup(name = unique(.$columngroup_name), columns = .$group_columns))

  return(list(headers, sketch))
}

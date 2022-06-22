format_colwidth_workaround <- function(x) {
  whattoadd <- rep("_", 22) |> stringr::str_c(collapse = "")

  levels <- c(
    "<=1h",
    ">1h - <=1d",
    ">1d - <=7d",
    ">7d - <=1m",
    ">1m - <=1a",
    ">1a - <=10a",
    ">10a",
    "static",
    whattoadd
  )

  replace_hard <- function(x, replacement) {
    replacement
  }

  column_types_original <- x |>
    dplyr::summarise(dplyr::across(dplyr::everything(), class)) |>
    unlist() |>
    stringr::str_sub(end = 1) |>
    stringr::str_c(collapse = "")

  table_to_add <- x |>
    dplyr::slice(1) |>
    dplyr::mutate(dplyr::across(where(is.numeric), replace_hard, NA_real_)) |>
    dplyr::mutate(dplyr::across(where(is.character), replace_hard, NA_character_)) |>
    dplyr::mutate(dplyr::across(where(lubridate::is.Date), replace_hard, lubridate::NA_Date_)) |>
    dplyr::mutate(dplyr::across(where(is.factor), replace_hard, NA_character_)) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(c("min", "max")), replace_hard, whattoadd)) |>
    readr::type_convert(column_types_original)

  x |>
    dplyr::bind_rows(table_to_add) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(c("min", "max")),
        factor,
        levels = levels))
}

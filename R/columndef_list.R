columndef_list <- function(x) {
  columns <- x |>
    names() |>
    bind_cols(read_column_types() |> stringr::str_split("")) |>
    purrr::set_names(c("name", "type"))

  columns_with_range_slider <- columns %>% define_column_range_slider()
  columns_sticky <- columns %>% define_columns_sticky()
  columns_url <- columns %>% define_columns_url()
  columns_binary <- columns %>% define_column_binary()
  columns_comment <- columns %>% define_column_comment()
  # columns_latex <- columns %>% define_column_latex()

  c(
    columns_with_range_slider,
    columns_sticky,
    columns_url,
    columns_binary,
    columns_comment
  )
}
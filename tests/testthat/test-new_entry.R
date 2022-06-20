test_that("Equal column names", {
  get_unique_column_names_from_new_entries <- function () {
    NEW_ENTRY_DIRECTORY %>%
    list.files(full.names = TRUE, pattern = ".txt") %>%
    purrr::discard(str_detect, "example.txt") %>%
    map(read_new_entry) %>%
    map(names) %>%
    unlist() %>%
    unique()
  }

  expect_equal(get_unique_column_names_from_new_entries(), true_column_names())
})

test_that("data types are correct", {
  convert_columns_to_true_data_types <- function () {
    NEW_ENTRY_DIRECTORY %>%
    list.files(full.names = TRUE, pattern = ".txt") %>%
    purrr::discard(str_detect, "example.txt") %>%
    map(read_new_entry) %>%
    map(~readr::type_convert(.x, col_types = true_column_types()))
  }

  expect_silent(convert_columns_to_true_data_types())
})

test_that("column categories are correct", {
  new_entry <- NEW_ENTRY_DIRECTORY %>%
    list.files(full.names = TRUE, pattern = ".txt") %>%
    purrr::map(read_new_entry) %>%
    purrr::reduce(bind_rows)

  expect_true({
    new_entry %>%
    pull(Domain) %>%
    magrittr::is_in(COLUMN_CATEGORIES_DOMAIN) %>%
    all()})
})



library(purrr)
library(tidyr)
library(readr)
library(dplyr)
library(magrittr)
library(stringr)

test_that("Equal column names", {
  get_unique_column_names_from_new_entries <- function () {
    NEW_ENTRY_DIRECTORY |>
    list.files(full.names = TRUE, pattern = ".txt") |>
    discard(str_detect, "example.txt") |>
    map(read_new_entry) |>
    map(names) |>
    unlist() |>
    unique()
  }

  expect_equal(get_unique_column_names_from_new_entries(), true_column_names())
})

print("yes, here!")

test_that("data types are correct", {
  convert_columns_to_true_data_types <- function () {
    NEW_ENTRY_DIRECTORY |>
    list.files(full.names = TRUE, pattern = ".txt") |>
    discard(str_detect, "example.txt") |>
    map(read_new_entry) |>
    map(~type_convert(.x, col_types = true_column_types()))
  }

  expect_silent(convert_columns_to_true_data_types())
})

print("yes, here!")

test_that("column categories are correct", {
  new_entry <- NEW_ENTRY_DIRECTORY |>
  list.files(full.names = TRUE, pattern = ".txt") |>
    map(read_new_entry) |>
    reduce(dplyr::bind_rows)

  expect_true({
    new_entry |>
    dplyr::pull(Domain) |>
    is_in(COLUMN_CATEGORIES_DOMAIN) |>
    all()})
})



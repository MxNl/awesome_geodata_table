## code to prepare `awesome_table_raw` dataset goes here

library(readr)
library(dplyr)

awesome_table_raw <- read_csv2(  "inst/extdata/awesome_geodata_table.csv")
awesome_table_raw <- awesome_table_raw |>
  dplyr::slice(-c(1, 2))


usethis::use_data(awesome_table_raw, overwrite = TRUE)

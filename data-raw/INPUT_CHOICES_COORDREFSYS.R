## code to prepare `INPUT_CHOICES_COORDREFSYS` dataset goes here
INPUT_CHOICES_COORDREFSYS <- rgdal::make_EPSG() |>
  as_tibble() |>
  mutate(choices = stringr::str_glue("EPSG: {code}, Name: {note}, PROJ4: {prj4}")) |>
  pull(choices)

usethis::use_data(INPUT_CHOICES_COORDREFSYS, overwrite = TRUE)

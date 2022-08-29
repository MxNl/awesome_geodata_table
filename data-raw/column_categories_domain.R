column_categories_domain <- c(
  "Chemistry",
  "Lithosphere",
  "Biological classification",
  "Atmosphere",
  "Paleontology",
  "Oceans",
  "Ecology",
  "Land surface",
  "Biosphere",
  "Geophysics",
  "Cryosphere",
  "Lakes & Rivers",
  "Human Dimensions",
  "Fisheries",
  "Agriculture"
) %>%
  sort()

usethis::use_data(column_categories_domain, overwrite = TRUE)

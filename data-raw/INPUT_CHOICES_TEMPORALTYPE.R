## code to prepare `INPUT_CHOICES_TEMPORALTYPE` dataset goes here
INPUT_CHOICES_TEMPORALTYPE <- c("dynamic", "aggregated-dynamic", "semi-static", "static")

usethis::use_data(INPUT_CHOICES_TEMPORALTYPE, overwrite = TRUE)

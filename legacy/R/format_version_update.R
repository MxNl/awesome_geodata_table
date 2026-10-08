format_version_update <- function(x) {
  x %>%
    mutate(
    version_update_icons = dplyr::case_when(
      `Version updates` == "yes" ~ "check-circle",
      `Version updates` == "no" ~ "times-circle",
      TRUE ~ "question-circle"
    ),
    version_update_icon_colors = dplyr::case_when(
      `Version updates` == "yes" ~ "#66DE93",
      `Version updates` == "no" ~ "#FF616D",
      TRUE ~ "grey"
    )
  )
}
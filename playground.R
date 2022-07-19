temporal_res_keep <- COLUMN_CATEGORIES_TEMPRES[
  which(COLUMN_CATEGORIES_TEMPRES == inputmin):
    which(COLUMN_CATEGORIES_TEMPRES == inputmax)
] %>%
  c("static")

temporal_coverage_date <- c(inputcovmin, inputcovmax + 1) %>%
  str_c("-01-01") %>%
  ymd()

table_data %>%
  slice(1:10) %>%
  filter(
    # conditional(length(input$`Dataset name`) > 0, `Dataset name` %in% input$`Dataset name`),
    # conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter),
    # conditional(length(input$spatial_coverage) > 0, `Coverage (spatial)` %in% input$spatial_coverage),
    # conditional(length(input$Tags) > 0, str_detect(Tags, str_c(input$Tags, collapse = "|"))),
    # conditional(length(input$Domain) > 0, Domain %in% input$Domain),
    # conditional(length(input$spatial_res) > 0, `min [m]` >= input$spatial_res[1] & `max [m]` <= input$spatial_res[2]),
    conditional(TRUE,
                (start >= temporal_coverage_date[1] & end <= temporal_coverage_date[2] | is.na(end)) |
                  (is.na(start) & is.na(start))),
    conditional(TRUE, min %in% temporal_res_keep & max %in% temporal_res_keep)
  )
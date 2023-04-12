filter_table <- function() {
  # Filter data
      temporal_res_keep <- column_categories_tempres[
        1:which(column_categories_tempres == input$temporal_res)
      ] %>%
        c("static")

      temporal_coverage_date <- c(input$temporal_coverage[1], input$temporal_coverage[2] + 1) %>%
        str_c("-01-01") %>%
        ymd()

      table_data %>%
        filter(
          conditional(length(input$`Dataset name`) > 0, `Dataset name` %in% input$`Dataset name`),
          conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter),
          conditional(length(input$spatial_coverage) > 0, `Coverage (spatial)` %in% input$spatial_coverage),
          conditional(length(input$Tags) > 0, str_detect(Tags, str_c(input$Tags, collapse = "|"))),
          conditional(length(input$Domain) > 0, Domain %in% input$Domain),
          conditional(length(input$spatial_res) > 0, (`max [m]` <= input$spatial_res | is.na(`max [m]`))),
          conditional(length(input$temporal_coverage) > 0, (start <= temporal_coverage_date[1] | is.na(start)) & (end >= temporal_coverage_date[2] | is.na(end))),
          conditional(length(input$temporal_res) > 0, max %in% temporal_res_keep)
        )
}
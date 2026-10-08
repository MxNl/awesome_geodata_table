test <- tibble(
  name = rep("start_end", 2),
  value = c(1231, 5555)
  )

test %>%
  group_by(name) %>%
  mutate(
    name = ifelse(row_number() == 1 & n() == 2, "start", name),
    name = ifelse(row_number() == 2 & n() == 2, "end", name)
  )

test %>%
  separate_rows(name, sep = "_") %>%
  group_by(name)

temporal_res_keep <- INPUT_CHOICES_TEMPRES[
  which(INPUT_CHOICES_TEMPRES == inputmin):
    which(INPUT_CHOICES_TEMPRES == inputmax)
] %>%
  c("static")

inputcovmin <- 1945
inputcovmax <- 2005

temporal_coverage_date <- c(inputcovmin, inputcovmax + 1) %>%
  str_c("-01-01") %>%
  ymd()

table_data %>%
  slice(1:10) %>%
  filter(
    conditional(length(input$`Dataset name`) > 0, `Dataset name` %in% input$`Dataset name`),
    conditional(length(input$Parameter) > 0, Parameter %in% input$Parameter),
    conditional(length(input$spatial_coverage) > 0, `Coverage (spatial)` %in% input$spatial_coverage),
    conditional(length(input$Tags) > 0, str_detect(Tags, str_c(input$Tags, collapse = "|"))),
    conditional(length(input$Domain) > 0, Domain %in% input$Domain),
    conditional(length(input$spatial_res) > 0, `min [m]` >= input$spatial_res[1] & `max [m]` <= input$spatial_res[2])
    conditional(TRUE,
                (start <= temporal_coverage_date[1] & end >= temporal_coverage_date[2] | is.na(end)) |
                  (is.na(start) & is.na(start))),
    # conditional(TRUE, min %in% temporal_res_keep & max %in% temporal_res_keep)
  )

table_data %>%
  filter((start <= temporal_coverage_date[1] | is.na(start)) & (end >= temporal_coverage_date[2] | is.na(end))) %>%
  View()
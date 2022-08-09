table_raw <- agt_raw_read()
column_types <- get_column_types(table_raw)
double_column_names <- get_double_column_names(table_raw)
table_data <- table_raw %>%
  agt_table() %>%
  agt_prepare(column_types)
table_config <- agt_configure(table_data, double_column_names, column_types)
spatial_res_range <- c(table_data$`min [m]`, table_data$`max [m]`) %>%
  range(na.rm = TRUE)
temporal_cov_range <- c(table_data$start, table_data$end) %>%
  range(na.rm = TRUE) %>%
  year()
temporal_res_unique <- COLUMN_CATEGORIES_TEMPRES %>% discard(str_detect, "static")
test_that("the widget is built with every filter column filterable", {
  schema <- read_schema(metadata_dir)
  data <- read_metadata(metadata_dir)
  widget <- agt_table(data, schema)
  expect_s3_class(widget, "reactable")
  expect_equal(widget$elementId, AGT_TABLE_ID)

  columns <- widget$x$tag$attribs$columns
  ids <- vapply(columns, `[[`, character(1), "id")
  filter_columns <- c(
    "name", "parameter", "tags", "domain", "coverage_spatial", "access", "data_type",
    "res_spatial_finest_m", "res_temporal_finest_rank", "coverage_start_year"
  )
  for (col in filter_columns) {
    def <- columns[[match(col, ids)]]
    expect_true(isTRUE(def$filterable), info = col)
    expect_false(is.null(def$filterMethod), info = col)
  }
  expect_true(isTRUE(columns[[match("search_text", ids)]]$searchable))
})

test_that("the filter panel offers every multi-select used by the table", {
  schema <- read_schema(metadata_dir)
  data <- read_metadata(metadata_dir)
  html <- as.character(agt_filters(data, schema))
  for (col in c("name", "parameter", "tags", "domain", "coverage_spatial", "access", "data_type")) {
    expect_match(html, sprintf('data-filter="%s"', col), fixed = TRUE)
  }
  expect_match(html, 'id="agt-config"', fixed = TRUE)
})

test_that("export columns are the raw metadata fields", {
  schema <- read_schema(metadata_dir)
  cols <- agt_export_columns(schema)
  expect_equal(cols[1:4], c("id", "name", "parameter", "unit"))
  expect_false(any(duplicated(cols)))
  expect_true(all(setdiff(cols, c("parameter", "unit")) %in% names(schema$datasets)))
})

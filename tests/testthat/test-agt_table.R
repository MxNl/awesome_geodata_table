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
    "res_spatial_finest_m", "res_temporal_finest_rank", "coverage_start_year",
    "variable", "license_class", "bbox_west", "row_key"
  )
  for (col in filter_columns) {
    def <- columns[[match(col, ids)]]
    expect_true(isTRUE(def$filterable), info = col)
    expect_false(is.null(def$filterMethod), info = col)
  }
  expect_true(isTRUE(columns[[match("search_text", ids)]]$searchable))
  expect_equal(widget$x$tag$attribs$selection, "multiple")
})

test_that("search text includes variable labels and synonyms", {
  schema <- read_schema(metadata_dir)
  data <- read_metadata(metadata_dir)
  widget <- agt_table(data, schema)
  search <- jsonlite::fromJSON(as.character(widget$x$tag$attribs$data))$search_text
  expect_true(any(grepl("grundwasserneubildung", search, fixed = TRUE)))
})

test_that("the filter panel offers every multi-select used by the table", {
  schema <- read_schema(metadata_dir)
  data <- read_metadata(metadata_dir)
  html <- as.character(agt_filters(data, schema))
  for (col in c("name", "parameter", "variable", "tags", "domain", "coverage_spatial", "access", "data_type", "license_class")) {
    expect_match(html, sprintf('data-filter="%s"', col), fixed = TRUE)
  }
  expect_match(html, 'id="agt-config"', fixed = TRUE)
  expect_equal(lengths(regmatches(html, gregexpr('class="agt-preset"', html))), length(schema$presets))
})

test_that("export columns are the raw metadata fields", {
  schema <- read_schema(metadata_dir)
  cols <- agt_export_columns(schema)
  expect_equal(cols[1:4], c("id", "name", "parameter", "unit"))
  expect_false(any(duplicated(cols)))
  expect_true(all(setdiff(cols, c("parameter", "unit", "variable")) %in% names(schema$datasets)))
})

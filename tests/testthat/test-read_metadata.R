test_that("the repository metadata is valid", {
  schema <- read_schema(metadata_dir)
  datasets <- read_metadata_csv(file.path(metadata_dir, "datasets.csv"))
  parameters <- read_metadata_csv(file.path(metadata_dir, "parameters.csv"))
  problems <- validate_metadata(datasets, parameters, schema)
  expect_equal(nrow(problems), 0, info = paste(capture.output(print(problems, n = 50)), collapse = "\n"))
})

test_that("read_metadata returns one typed row per parameter", {
  x <- read_metadata(metadata_dir)
  parameters <- read_metadata_csv(file.path(metadata_dir, "parameters.csv"))

  expect_equal(nrow(x), nrow(parameters))
  expect_false(anyDuplicated(x[c("id", "parameter")]) > 0)
  expect_type(x$res_spatial_finest_m, "double")
  expect_type(x$res_temporal_finest_rank, "integer")
  expect_type(x$coverage_start_year, "integer")
  expect_true(all(c("id", "name", "parameter", "unit", "domain", "download_url") %in% names(x)))
})

test_that("all legacy datasets survived the migration", {
  legacy_ids <- c(
    "caravan", "clms-imperviousness", "cordex", "corine-land-cover", "earthenv-topography",
    "era5-land", "eu-mohp", "glc-share", "glwd-1", "gmia", "grdc", "gsim", "hydroatlas",
    "igrac-ggis", "jrc-lai-europe", "openstreetmap", "pesticide-risk", "soilgrids", "ufz-duerremonitor"
  )
  x <- read_metadata(metadata_dir)
  expect_true(all(legacy_ids %in% x$id))
  expect_gte(sum(x$id %in% legacy_ids), 189)
})

test_that("parameter values override dataset values, `none` clears them", {
  merged <- merge_metadata(fixture_datasets(), fixture_parameters())
  discharge <- merged[merged$parameter == "discharge", ]
  clay <- merged[merged$parameter == "clay content", ]
  expect_equal(discharge$coverage_end, "2020")
  expect_equal(discharge$coverage_start, "1990")
  expect_true(is.na(clay$coverage_end))

  p <- fixture_parameters()
  p$res_temporal_finest <- c(NA, NA, "none")
  merged <- merge_metadata(fixture_datasets(), p)
  expect_true(is.na(merged$res_temporal_finest[merged$parameter == "discharge"]))
})

test_that("parameter tags are added to dataset tags", {
  merged <- merge_metadata(fixture_datasets(), fixture_parameters())
  expect_equal(merged$tags[merged$parameter == "sand content"], "soil; texture; sand")
  expect_equal(merged$tags[merged$parameter == "clay content"], "soil; texture")
})

test_that("bounding boxes come from the region unless the dataset has its own", {
  schema <- read_schema(metadata_dir)
  d <- fixture_datasets()
  d$bbox_west <- c(NA, "0")
  d$bbox_south <- c(NA, "40")
  d$bbox_east <- c(NA, "20")
  d$bbox_north <- c(NA, "60")
  bbox <- merged_bbox(merge_metadata(d, fixture_parameters()), schema)
  expect_equal(unlist(bbox[1, ]), c(bbox_west = -180, bbox_south = -90, bbox_east = 180, bbox_north = 90))
  expect_equal(unlist(bbox[3, ]), c(bbox_west = 0, bbox_south = 40, bbox_east = 20, bbox_north = 60))
})

test_that("almost every parameter has a standard variable", {
  x <- read_metadata(metadata_dir)
  expect_gte(mean(!is.na(x$variable)), 0.95)
  expect_false(any(is.na(x$variable_label[!is.na(x$variable)])))
})

test_that("every repository snippet parses", {
  for (f in list.files(file.path(metadata_dir, "snippets"), pattern = "\\.R$", full.names = TRUE)) {
    expect_no_error(parse(file = f), message = basename(f))
  }
})

test_that("every dataset names its publishing institution", {
  datasets <- read_metadata_csv(file.path(metadata_dir, "datasets.csv"))
  expect_false(any(is.na(datasets$publisher)))
  # journals publish papers, not the data
  expect_false(any(grepl("^(nature|scientific data|wiley)", datasets$publisher, ignore.case = TRUE)))
})

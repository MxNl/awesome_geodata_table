schema <- read_schema(metadata_dir)

problems_for <- function(datasets = fixture_datasets(), parameters = fixture_parameters()) {
  validate_metadata(datasets, parameters, schema)
}

test_that("valid fixture passes", {
  expect_equal(nrow(problems_for()), 0)
})

test_that("vocabulary violations are reported", {
  d <- fixture_datasets()
  d$domain[1] <- "Soils"
  d$res_temporal_finest[2] <- "≤ 1 d"
  p <- problems_for(d)
  expect_setequal(p$field, c("domain", "res_temporal_finest"))
  expect_true(all(p$file == "datasets.csv"))
  expect_equal(p$row[p$field == "domain"], 2L) # header is line 1
})

test_that("type violations are reported", {
  d <- fixture_datasets()
  d$download_url[1] <- "www.example.org"
  d$res_spatial_finest_m[2] <- "1 km"
  d$coverage_start[2] <- "1990-01-01"
  d$tags[1] <- "Soil, texture"
  expect_setequal(problems_for(d)$field, c("download_url", "res_spatial_finest_m", "coverage_start", "tags"))
})

test_that("required values and columns are enforced", {
  d <- fixture_datasets()
  d$access[1] <- NA
  expect_equal(problems_for(d)$problem, "required value missing")

  d <- fixture_datasets()[setdiff(names(fixture_datasets()), "download_url")]
  expect_equal(problems_for(d)$problem, "required column missing")
})

test_that("identity and references are checked", {
  d <- fixture_datasets()
  d$id[2] <- "ds-a"
  expect_true("duplicated id" %in% problems_for(d)$problem)

  p <- fixture_parameters()
  p$dataset_id[3] <- "ds-x"
  problems <- problems_for(parameters = p)$problem
  expect_true("unknown dataset id" %in% problems)
  expect_true("dataset has no parameters" %in% problems)

  p <- fixture_parameters()
  p$parameter[2] <- "clay content"
  expect_true("duplicated parameter within dataset" %in% problems_for(parameters = p)$problem)
})

test_that("unknown columns are rejected, dataset fields may be overridden", {
  p <- fixture_parameters()
  p$colour <- "red"
  expect_equal(problems_for(parameters = p)$problem, "unknown column")

  p <- fixture_parameters()
  p$res_temporal_finest <- c(NA, "none", "weekly")
  expect_equal(nrow(problems_for(parameters = p)), 0)
  p$res_temporal_finest[3] <- "biweekly"
  expect_equal(problems_for(parameters = p)$field, "res_temporal_finest")
})

test_that("inconsistent ranges are reported after inheritance", {
  d <- fixture_datasets()
  d$res_spatial_finest_m[2] <- "9000"
  expect_true(any(grepl("finest spatial", problems_for(d)$problem)))

  p <- fixture_parameters()
  p$res_temporal_finest <- c(NA, NA, "yearly") # dataset coarsest is monthly
  expect_true(any(grepl("finest temporal", problems_for(parameters = p)$problem)))

  p <- fixture_parameters()
  p$coverage_end[3] <- "1980" # starts 1990
  expect_true(any(grepl("starts after", problems_for(parameters = p)$problem)))
})

test_that("assert_valid_metadata gives a readable report", {
  d <- fixture_datasets()
  d$domain[1] <- "Soils"
  expect_error(assert_valid_metadata(d, fixture_parameters(), schema), "datasets.csv:2 \\[domain\\]")
})

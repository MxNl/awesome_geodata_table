test_that("the repository dictionary is valid", {
  expect_equal(validate_dictionary(read_dictionary(metadata_dir)), character())
})

test_that("dictionary problems are reported", {
  d <- list(list(en = "soil", de = "Boden"), list(en = "ground", de = character()), list(en = "Soil", de = "Erde"))
  problems <- validate_dictionary(d)
  expect_true(any(grepl("concept 2 needs English and German", problems)))
  expect_true(any(grepl("'soil' belongs to several concepts", problems)))
})

test_that("normalise_text folds case, umlauts, accents and punctuation", {
  expect_equal(normalise_text("Grundwasserstände"), " grundwasserstaende ")
  expect_equal(normalise_text("Dürre-Monitor (UFZ)"), " duerre monitor ufz ")
  expect_equal(normalise_text("Straße"), " strasse ")
  expect_equal(normalise_text("Évaporation"), " evaporation ")
  expect_equal(normalise_text(NA), "  ")
})

test_that("variable labels are covered by the dictionary", {
  terms <- unlist(dictionary_terms(read_dictionary(metadata_dir)))
  labels <- normalise_text(setdiff(vocab_labels(read_schema(metadata_dir), "variable"), "Other"))
  # every label contains a dictionary term at a word start (as matched in the
  # browser), so German searches reach the rows of every variable
  covered <- vapply(labels, \(l) any(stringr::str_detect(l, stringr::fixed(paste0(" ", terms)))), logical(1))
  expect_true(all(covered), info = paste(labels[!covered], collapse = ", "))
})

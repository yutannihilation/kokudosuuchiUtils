context("extract_codelist_urls")

test_that("extract_codelist_urls() works", {
  d <- extract_codelist_urls("test-split.html")
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 1L)
})

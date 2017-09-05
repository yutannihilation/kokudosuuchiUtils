context("parse_table")

parse_test_table <- function(html_file) {
  parse_tables(split_table(rvest::html_nodes(xml2::read_html(html_file), "tr")))
}

test_that("parse_table() works", {
  l <- parse_test_table("test-split.html")

  expect_equal(nrow(l[[1]]), 2L)
  expect_equal(colnames(l[[1]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
  expect_equal(nrow(l[[2]]), 3L)
  expect_equal(colnames(l[[2]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
})

test_that("parse_table() works", {
  d <- parse_test_table("test-parse.html")[[1]]

  expect_equal(nrow(d), 7L)
  expect_equal(colnames(d), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
  expect_equal(d$"\u5c5e\u6027\u540d"[4], "\u5927\u9805\u76ee1_\u4e2d\u9805\u76ee1_\u5c0f\u9805\u76ee1")
  expect_equal(d$"\u5c5e\u6027\u540d"[5], "\u5927\u9805\u76ee1_\u4e2d\u9805\u76ee1_\u5c0f\u9805\u76ee2")
})

test_that("parse_table() works", {
  d <- parse_table(rvest::html_nodes(xml2::read_html("test-split5.html"), "tr"))

  expect_equal(nrow(d), 2L)
})

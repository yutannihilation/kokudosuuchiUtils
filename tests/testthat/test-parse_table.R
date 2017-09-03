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

context("parse_table")

parse_test_table <- function(html_file) {
  parse_tables(split_table(rvest::html_nodes(xml2::read_html(html_file), "tr")))
}

test_that("parse_table() works for for HTML with two tables + note", {
  l <- parse_test_table("with-note.html")

  expect_equivalent(purrr::map_int(l, nrow), c(2L, 3L))
  expect_equal(colnames(l[[1]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
  expect_equal(colnames(l[[2]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
})

test_that("parse_table() works for HTML with a nested table", {
  d <- parse_test_table("nested-table.html")[[1]]

  expect_equal(nrow(d), 7L)
  expect_equal(colnames(d), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
  expect_equal(d$"\u5c5e\u6027\u540d"[4], "\u5927\u9805\u76ee1_\u4e2d\u9805\u76ee1_\u5c0f\u9805\u76ee1")
  expect_equal(d$"\u5c5e\u6027\u540d"[5], "\u5927\u9805\u76ee1_\u4e2d\u9805\u76ee1_\u5c0f\u9805\u76ee2")
})

test_that("parse_table() works for HTML with table with empty rows", {
  d <- parse_table(rvest::html_nodes(xml2::read_html("with-empty-rows.html"), "tr"))

  expect_equal(nrow(d), 2L)
})

test_that("parse_table() works for HTML with table without rows", {
  l <- parse_test_table("table-without-rows.html")

  expect_equivalent(purrr::map_int(l, nrow), c(2L, 1L))
  expect_equal(colnames(l[[1]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
  expect_equal(colnames(l[[2]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
})

test_that("parse_table() works for HTML with table without rows and empty leftmost", {
  l <- parse_test_table("table-without-rows-and-empty-leftmost.html")

  expect_equivalent(purrr::map_int(l, nrow), c(2L, 1L))
  expect_equal(colnames(l[[1]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
  expect_equal(colnames(l[[2]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
})


test_that("parse_table() works for HTML with table without rows and another leftmost", {
  l <- parse_test_table("table-without-rows-and-another-leftmost.html")

  expect_equivalent(purrr::map_int(l, nrow), c(2L, 1L))
  expect_equal(colnames(l[[1]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
  expect_equal(colnames(l[[2]]), c("\u5c5e\u6027\u540d", "\u8aac\u660e", "\u5c5e\u6027\u306e\u578b"))
})

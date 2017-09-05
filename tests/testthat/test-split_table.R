context("split_table")

test_that("split_table works for HTML with two tables + note", {
  tr_nodeset <- rvest::html_nodes(xml2::read_html("test-split.html"), "tr")
  tr_nodeset_list <- split_table(tr_nodeset)

  expect_equal(length(tr_nodeset_list), 2L)
  expect_equivalent(purrr::map_int(tr_nodeset_list, length), c(3L, 4L))
})

test_that("split_table works for HTML with tables where the vertically long cell is overwrapped", {
  tr_nodeset <- rvest::html_nodes(xml2::read_html("test-split2.html"), "tr")
  tr_nodeset_list <- split_table(tr_nodeset)

  expect_equal(length(tr_nodeset_list), 2L)
  expect_equivalent(purrr::map_int(tr_nodeset_list, length), c(2L, 2L))
})

test_that("split_table works for HTML with two tables and one ignorable table", {
  tr_nodeset <- rvest::html_nodes(xml2::read_html("test-split3.html"), "tr")
  tr_nodeset_list <- split_table(tr_nodeset)

  expect_equal(length(tr_nodeset_list), 2L)
  expect_equivalent(purrr::map_int(tr_nodeset_list, length), c(3L, 4L))
})

test_that("split_table works for HTML with tables without rows", {
  tr_nodeset <- rvest::html_nodes(xml2::read_html("test-split4.html"), "tr")
  tr_nodeset_list <- split_table(tr_nodeset)

  expect_equal(length(tr_nodeset_list), 2L)
  expect_equivalent(purrr::map_int(tr_nodeset_list, length), c(3L, 2L))
})

test_that("split_table works for HTML with tables with empty row", {
  tr_nodeset <- rvest::html_nodes(xml2::read_html("test-split5.html"), "tr")
  tr_nodeset_list <- split_table(tr_nodeset)

  expect_equal(length(tr_nodeset_list), 1L)
  # confirm the empty row is not removed
  expect_equal(length(rvest::html_nodes(tr_nodeset_list[[1]][[3]], "td")), 0L)
  expect_equivalent(purrr::map_int(tr_nodeset_list, length), c(4L))
})

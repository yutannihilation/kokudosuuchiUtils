#' Split Tables
#'
#' @export
split_table <- function(tr_nodeset, pattern_lefttop_cell = ZOKUSEI_PATTERN) {
  # remove empty tr
  tr_nodeset <- tr_nodeset %>%
    purrr::keep(~ length(rvest::html_nodes(., "td")) > 0)

  metadata <- get_tr_metadata(tr_nodeset)

  # preserve tables matched the pattern only
  indices_table_top <- which(metadata$is_start_of_different_table &
                               stringr::str_detect(metadata$row_label, pattern = pattern_lefttop_cell))

  # filter out rows without bgcolor ----------------
  # expected_rows can overwrap
  preserve_row <- rep(FALSE, length(tr_nodeset))
  for (i in indices_table_top) {
    preserve_row[i:(i + metadata$expected_rows[i] - 1)] <- TRUE
  }

  metadata <- metadata[preserve_row, ]

  # split table ----------------------
  table_id <- cumsum(metadata$is_start_of_different_table)
  tr_nodeset_list <- split(tr_nodeset[preserve_row], table_id)

  # filter out tables if it doesn't have a header -----------------
  unname(tr_nodeset_list[metadata$is_header[metadata$is_start_of_different_table]])
}


get_tr_metadata <- function(tr_nodeset) {
  is_tr_headerish <- !is.na(purrr::map_chr(tr_nodeset, rvest::html_attr, "bgcolor"))

  are_tds_headerish <- tr_nodeset %>%
    purrr::map(rvest::html_nodes, "td") %>%
    purrr::map(purrr::map_chr, rvest::html_attr, "bgcolor") %>%
    purrr::map(~ !is.na(.))

  is_first_td_headerish <- purrr::map_lgl(are_tds_headerish, 1L)
  are_all_tds_headerish  <- purrr::map_lgl(are_tds_headerish, all)

  is_start_of_different_table <- is_tr_headerish | is_first_td_headerish

  leftmost_td_nodeset <- rvest::html_node(tr_nodeset, "td")

  row_label <- rvest::html_text(leftmost_td_nodeset)

  expected_rows <- leftmost_td_nodeset %>%
    rvest::html_attr("rowspan", default = "1") %>%
    as.integer()

  is_header <- is_tr_headerish | are_all_tds_headerish

  # if it is next to the table without rows, it is probably the part of the table
  is_header_without_rows <- is_header & expected_rows == 1L
  is_next_to_header_without_rows <- c(FALSE, dplyr::lag(is_header_without_rows)[-1])
  expected_rows[is_header_without_rows] <- expected_rows[is_header_without_rows] + expected_rows[is_next_to_header_without_rows]
  is_start_of_different_table <- is_start_of_different_table & !is_next_to_header_without_rows

  tibble::tibble(is_tr_headerish,
                 is_first_td_headerish,
                 are_all_tds_headerish,
                 is_start_of_different_table,
                 is_header,
                 expected_rows,
                 row_label)
}


#' @export
split_tables <- function(tr_nodeset_list, pattern_lefttop_cell = ZOKUSEI_PATTERN) {
  purrr::map(tr_nodeset_list, split_table, pattern_lefttop_cell = pattern_lefttop_cell) %>%
    purrr::flatten()
}

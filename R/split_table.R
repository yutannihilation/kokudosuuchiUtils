#' Split Tables
#'
#' @export
split_table <- function(tr_nodeset, pattern_lefttop_cell = ZOKUSEI_PATTERN) {
  # remove empty tr
  tr_nodeset <- tr_nodeset %>%
    purrr::keep(~ length(rvest::html_nodes(., "td")) > 0)

  is_tr_headerish <- !is.na(purrr::map_chr(tr_nodeset, rvest::html_attr, "bgcolor"))

  are_tds_headerish <- tr_nodeset %>%
    purrr::map(rvest::html_nodes, "td") %>%
    purrr::map(purrr::map_chr, rvest::html_attr, "bgcolor") %>%
    purrr::map(~ !is.na(.))

  is_first_td_headerish <- purrr::map_lgl(are_tds_headerish, 1L)
  are_all_tds_headerish  <- purrr::map_lgl(are_tds_headerish, all)

  is_start_of_different_table <- is_tr_headerish | is_first_td_headerish
  indices_table_top <- which(is_start_of_different_table)

  # filter out rows without bgcolor ----------------
  td_nodeset_lefttop_of_table <- rvest::html_node(tr_nodeset[is_start_of_different_table], "td")

  td_nodeset_lefttop_of_table <- td_nodeset_lefttop_of_table %>%
    purrr::keep(stringr::str_detect, pattern = pattern_lefttop_cell)

  expected_rows <- td_nodeset_lefttop_of_table %>%
    rvest::html_attr("rowspan", default = "1") %>%
    as.integer()

  # expected_rows can overwrap
  preserve_row <- rep(FALSE, length(tr_nodeset))
  for (i in seq_along(expected_rows)) {
    preserve_row[indices_table_top[i]:(indices_table_top[i] + expected_rows[i] - 1)] <- TRUE
  }

  tr_nodeset <- tr_nodeset[preserve_row]
  is_start_of_different_table <- is_start_of_different_table[preserve_row]
  is_tr_headerish <- is_tr_headerish[preserve_row]
  are_all_tds_headerish <- are_all_tds_headerish[preserve_row]
  expected_rows <- expected_rows[preserve_row]

  # split table ----------------------
  is_header <- is_tr_headerish | are_all_tds_headerish
  is_header_without_rows <- is_header & expected_rows == 1L
  # if it is next to the table without rows, it is probably the part of the table
  is_start_of_different_table <- is_start_of_different_table & !c(FALSE, dplyr::lag(is_header_without_rows)[-1])
  table_id <- cumsum(is_start_of_different_table)
  tr_nodeset_list <- split(tr_nodeset, table_id)

  # filter out tables if it doesn't have a header or the filter_pattern doesn't match -----------------
  has_header <- is_header[is_start_of_different_table]

  unname(tr_nodeset_list[has_header])
}


get_tr_metadata <- function(tr_nodeset) {

}


#' @export
split_tables <- function(tr_nodeset_list, pattern_lefttop_cell = ZOKUSEI_PATTERN) {
  purrr::map(tr_nodeset_list, split_table, pattern_lefttop_cell = pattern_lefttop_cell) %>%
    purrr::flatten()
}

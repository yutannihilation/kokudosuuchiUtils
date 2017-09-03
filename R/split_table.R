#' Split Tables
#'
#' @export
split_table <- function(tr_nodeset) {
  has_bgcolor_tr <- !is.na(purrr::map_chr(tr_nodeset, rvest::html_attr, "bgcolor"))

  has_bgcolor_tds <- tr_nodeset %>%
    purrr::map(rvest::html_nodes, "td") %>%
    purrr::map(purrr::map_chr, rvest::html_attr, "bgcolor") %>%
    purrr::map(~ !is.na(.))

  has_bgcolor_first_td <- purrr::map_lgl(has_bgcolor_tds, dplyr::first)
  is_start_of_different_table <- has_bgcolor_tr | has_bgcolor_first_td
  table_top_indices <- which(is_start_of_different_table)

  # filter out rows without bgcolor ----------------
  expected_rows <- tr_nodeset[is_start_of_different_table] %>%
    purrr::map(rvest::html_node, "td") %>%
    purrr::map_chr(rvest::html_attr, "rowspan", default = "1") %>%
    as.integer()

  # expected_rows can overwrap
  preserve_row <- rep(FALSE, length(tr_nodeset))
  for (i in seq_along(expected_rows)) {
    preserve_row[table_top_indices[i]:(table_top_indices[i] + expected_rows[i] - 1)] <- TRUE
  }

  tr_nodeset <- tr_nodeset[preserve_row]
  is_start_of_different_table <- is_start_of_different_table[preserve_row]
  has_bgcolor_tr <- has_bgcolor_tr[preserve_row]
  has_bgcolor_tds <- has_bgcolor_tds[preserve_row]

  # split table ----------------------
  table_id <- cumsum(is_start_of_different_table)
  tr_nodeset_list <- split(tr_nodeset, table_id)

  # filter out tables without header -----------------
  has_bgcolor_all_td <- purrr::map_lgl(has_bgcolor_tds, all)
  is_header <- has_bgcolor_tr | has_bgcolor_all_td
  has_header <- is_header[is_start_of_different_table]

  tr_nodeset_list[has_header]
}

#' @export
split_tables <- function(tr_nodeset_list) {
  purrr::map(tr_nodeset_list, split_tables) %>%
    purrr::flatten()
}

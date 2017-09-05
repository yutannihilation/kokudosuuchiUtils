#' Parse tables
#'
#' @export
parse_table <- function(tr_nodeset) {
  header_row <- tr_nodeset[[1]]
  content_rows <- tr_nodeset[-1]

  try_remove_lefttop_cells(header_row, content_rows)

  header_col_names <- header_row %>%
    rvest::html_nodes("td") %>%
    rvest::html_text() %>%
    stringr::str_replace(COLNAME_FRILL_PATTERN, "")

  header_col_widths <- header_row %>%
    rvest::html_nodes("td") %>%
    rvest::html_attr("colspan", default = "1") %>%
    as.integer()

  number_of_cols <- sum(header_col_widths)
  indices_header_col <- head(cumsum(c(1L, header_col_widths)), length(header_col_widths))

  number_of_rows <- length(content_rows)

  # Extract rows ---------------------------------

  table_data <- purrr::imap_dfr(content_rows, extract_data_from_row)

  # Calculate the effect of colspans -----------------

  # cells with rowspan == 1 has no effect
  indices_vertically_long_cells <- which(table_data$rowspan > 1)
  table_data_adjusted <- table_data

  for (idx in indices_vertically_long_cells) {
    col_index_left     <- table_data_adjusted$col_index[idx]
    row_index_top      <- table_data_adjusted$row_index[idx] + 1L
    row_index_bottom   <- table_data_adjusted$row_index[idx] + table_data_adjusted$rowspan[idx] - 1L

    table_data_adjusted <- dplyr::mutate(
      table_data_adjusted,
      col_index = dplyr::if_else(
        col_index >= col_index_left &
          dplyr::between(row_index, row_index_top, row_index_bottom),
        col_index + table_data_adjusted$colspan[idx],
        col_index
      )
    )
  }

  # Construct character matrix with cells extracted ------------------------

  result <- matrix(NA_character_, ncol = number_of_cols,  nrow = number_of_rows)
  result[cbind(table_data_adjusted$row_index, table_data_adjusted$col_index)] <- table_data_adjusted$text

  for (idx in indices_vertically_long_cells) {
    col_idx <- table_data_adjusted$col_index[idx]
    row_idx <- table_data_adjusted$row_index[idx]
    colspan <- table_data_adjusted$colspan[idx]
    rowspan <- table_data_adjusted$rowspan[idx]
    cell_text <- table_data_adjusted$text[idx]

    if (is.na(cell_text)) {
      if (row_idx == 1L) stop("something is wrong")
      cell_text <- result[row_idx - 1, col_idx]
    }
    result[row_idx:(row_idx + rowspan - 1L), col_idx:(col_idx + colspan - 1L)] <- cell_text
  }

  # remove empty rows
  result <- result[rowSums(!is.na(result)) > 0, , drop = FALSE]

  # Construct the result data.frame ------------------------
  result_list <- list()
  col_index_groups <- split(seq_len(number_of_cols),
                            rep(seq_along(header_col_widths), header_col_widths))

  for (idx in seq_along(header_col_names)) {
    col_name <- header_col_names[idx]
    col_indices <- col_index_groups[[idx]]
    cols_list <- purrr::map(col_indices, ~ result[, .])

    if (length(col_indices) == 1L) {
      result_list[[col_name]] <- result[, col_indices]
      next
    }

    result_list[[col_name]] <- cols_list %>%
      purrr::reduce(~ dplyr::coalesce(stringr::str_c(.x, .y, sep = "_"), .x))
  }

  tibble::as_tibble(result_list)
}

#' @export
parse_tables <- function(tr_nodeset_list) {
  purrr::map(tr_nodeset_list, parse_table)
}

# see design/when-to-remove-top-left-cell.md
try_remove_lefttop_cells <- function(header_row, content_rows) {
  header_lefttop_td_node <- rvest::html_node(header_row, "td")
  content_lefttop_td_node <- rvest::html_node(content_rows[[1]], "td")

  # 1) The top-left header cell is vertically long
  if (!is.na(rvest::html_attr(header_lefttop_td_node, "rowspan"))) {
    xml2::xml_remove(header_lefttop_td_node)
  } else {
    # 2) The top-left header cell is NOT vertically long (and is not overwrapped by the last table)
    if (!is.na(rvest::html_attr(content_lefttop_td_node, "bgcolor"))) {
      xml2::xml_remove(header_lefttop_td_node)
      xml2::xml_remove(content_lefttop_td_node)
    }
  }
}

extract_data_from_row <- function(row_node, row_index) {
  cells     <- rvest::html_nodes(row_node, "td")

  colspan   <- as.integer(purrr::map_chr(cells, rvest::html_attr, "colspan", default = "1"))
  col_index <- utils::head(cumsum(c(1L, colspan)), length(cells))

  rowspan   <- as.integer(purrr::map_chr(cells, rvest::html_attr, "rowspan", default = "1"))

  text <- rvest::html_text(cells, trim = TRUE) %>%
    # replace empty cell with NA
    dplyr::if_else(stringr::str_detect(., "^\\s*$"), NA_character_, .)

  tibble::tibble(row_index,
                 col_index,
                 colspan,
                 rowspan,
                 text)
}

#' Read table
#'
#' @export
read_kokudosuuchi_table <- function(html_file) {
  tables <- xml2::read_html(html_file, encoding = "CP932") %>%
    rvest::html_nodes(css = "table table")

  tr_nodeset_list <- purrr::map(tables, rvest::html_nodes, css = "tr")

  tr_nodeset_list_split <- split_tables(tr_nodeset_list)
  parse_tables(tr_nodeset_list_split)
}

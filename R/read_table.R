#' Read table
#'
#' @export
read_kokudosuuchi_table <- function(html_file) {
  tr_nodeset_list <- get_tr_nodeset_from_html(html_file)

  tr_nodeset_list_split <- split_tables(tr_nodeset_list)
  parse_tables(tr_nodeset_list_split)
}

#' @export
get_tr_nodeset_from_html <- function(html_file) {
  xml2::read_html(html_file, encoding = "CP932") %>%
    rvest::html_nodes(css = "table table") %>%
    purrr::map(rvest::html_nodes, css = "tr")
}

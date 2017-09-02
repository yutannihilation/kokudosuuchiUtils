#' Fetch URLs Of Description Pages About Each Identifiers
#'
#' @export
fetch_description_urls <- function() {
  html <- xml2::read_html("http://nlftp.mlit.go.jp/ksj/index.html")
  a_nodes <- rvest::html_nodes(html, css = "td > a")

  url_relpath <- rvest::html_attr(a_nodes, "href")
  url <- glue::glue('http://nlftp.mlit.go.jp/ksj/{url_relpath}')
  name <- rvest::html_text(a_nodes)
  identifier <- stringi::stri_extract_first_regex(url_relpath, "(?<=KsjTmplt-).*?(?=(-v\\d+_\\d+)?\\.html)")

  tibble::tibble(url, name, identifier) %>%
    dplyr::filter(!is.na(identifier)) %>%
    dplyr::arrange(identifier)
}

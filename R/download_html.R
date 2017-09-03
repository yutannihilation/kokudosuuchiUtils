#' Fetch URLs Of Description Pages About Each Identifiers
#'
#' @export
fetch_datalist_urls <- function() {
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


#' Download All HTMLs
#'
#' @export
download_one_html_safely <- purrr::safely(function(url, destfile) {
  if (file.exists(destfile)) return(FALSE)

  curl::curl_download(url, destfile)
  Sys.sleep(1)
  return(TRUE)
})

#' @export
download_all_html <- function(urls, destfiles) {
  result <- purrr::map2(urls,
                        destfiles,
                        download_one_html_safely)

  if (any(purrr::map_lgl(result, ~ !is.null(.$error)))) {
    stop("some error happened")
  }
}

#' @export
download_all_datalist_html <- function() {
  datalist_urls <- KSJIdentifierDescriptionURL$url
  datalist_destfiles <- file.path(HTML_DIR, paste0("datalist-", basename(datalist_urls)))
  download_all_html(datalist_urls, datalist_destfiles)
}

#' @export
download_all_codelist_html <- function() {
  codelist_urls <- KSJCodesDescriptionURL$url
  codelist_destfiles <- file.path(HTML_DIR, paste0("datalist-", basename(codelist_urls)))
  download_all_html(codelist_urls, codelist_destfiles)
}


#' @export
extract_codelist_urls <- function(html_file) {
  td_nodes <- xml2::read_html(html_file, encoding = "CP932") %>%
    rvest::html_nodes(xpath = "//td[a]")

  text <- rvest::html_text(td_nodes)

  a_nodes_list <- purrr::map(td_nodes, rvest::html_nodes, xpath = "./a")

  url <- purrr::map(a_nodes_list, rvest::html_attr, "href")
  name <- purrr::map(a_nodes_list, rvest::html_text)

  tibble::tibble(text, url, name) %>%
    tidyr::unnest() %>%
    dplyr::filter(stringr::str_detect(url, "codelist")) %>%
    dplyr::mutate(url = sprintf("http://nlftp.mlit.go.jp/ksj/gml/codelist/%s", basename(.data$url)))
}

#' @export
extract_all_codelist_urls <- function() {
  datalist_files <- list.files(HTML_DIR, pattern = "datalist-.*\\.html", full.names = TRUE)
  rlang::set_names(datalist_files, basename(datalist_files))
  purrr::map_dfr(datalist_files, extract_codelist_urls, .id = "source")
}

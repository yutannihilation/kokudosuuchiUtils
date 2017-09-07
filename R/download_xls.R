#' Parse
#'
#' @export
# Download by browser; I don't know why download.file won't work...
fetch_shape_property_table_xls <- function() {
  xls_files <- tempfile(fileext = ".xls")
  on.exit(unlink(xls_files))

  curl::curl_download("http://nlftp.mlit.go.jp/ksj/gml/shape_property_table.xls", destfile = xls_files)
  sheets <- readxl::excel_sheets(xls_files)
  shape_property_table_xls <- purrr::map_dfr(sheets, ~ readxl::read_excel(xls_files, sheet = ., skip = 4))

  colnames(shape_property_table_xls) <- c("category", "item", "tag", "code", "name", "notes")

  shape_property_table_xls %>%
    # Work around for merged cells
    tidyr::fill(.data$category, .data$item, .data$tag) %>%
    dplyr::mutate(category = stringr::str_replace(.data$category, "\\n.*$", ""))
}

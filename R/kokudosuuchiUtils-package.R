#' Utilities For 'kokudosuuchi' Package
#'
#' @name kokudosuuchiUtils
#' @docType package
#' @importFrom magrittr %>%
#' @importFrom rlang .data
NULL

HTML_DIR <- "downloaded_html"

ZOKUSEI_PATTERN <- "\u5c5e\u6027\u60c5\u5831|\u5730\u7269\u60c5\u5831"

COLNAME_PATTERN <- "(?<=^\u5c5e\u6027(\u60c5\u5831|\u540d|\u9805\u76ee))(\\s*[\uff08\\(].*[\uff09\\)])$"

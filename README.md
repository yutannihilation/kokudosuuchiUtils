# kokudosuuchiUtils

[![Travis-CI Build Status](https://travis-ci.org/yutannihilation/kokudosuuchiUtils.svg?branch=master)](https://travis-ci.org/yutannihilation/kokudosuuchiUtils)

## Installation

``` r
# install.packages("devtools")
devtools::install_github("yutannihilation/kokudosuuchiUtils")
```
## Procedures

### Update the list of data description URLs

```r
KSJIdentifierDescriptionURL <- fetch_datalist_urls()
devtools::use_data(KSJIdentifierDescriptionURL, overwrite = TRUE)
file.copy("data/KSJIdentifierDescriptionURL.rda", "/path/to/kokudosuuchi/data/", overwrite = TRUE)
```

### Parse all data description HTMLs

```r
library(purrr)

download_all_datalist_html()

datalist_files <- list.files("downloaded_html", pattern = "datalist-.*\\.html", full.names = TRUE)
datalist_files <- set_names(datalist_files)
result_wrapped <- map(datalist_files, safely(read_kokudosuuchi_table))
discard(result_wrapped, ~ is.null(.$error))

result <- map(result_wrapped, "result")

normalize_colnames <- function(d) {
  colnames_orig <- colnames(d)
  colnames_normalized <- dplyr::recode(
    colnames_orig,
    "属性項目"   = "属性名",
    "地物名"     = "属性名",
    "関連役割名" = "属性名",
    "形状"       = "属性の型",
    "関連先"     = "属性の型"
  )
  `colnames<-`(d, colnames_normalized)
}

zokusei_tables <- result %>%
  map(keep, ~ ncol(.) == 3) %>%
  map(map_dfr, normalize_colnames, .id = "table_num") %>%
  dplyr::bind_rows(.id = "html_file") %>%
  dplyr::mutate(html_file = stringr::str_replace(html_file, "downloaded_html/datalist-", ""))

chibutsu_tables <- result %>%
  map(keep, ~ ncol(.) == 2) %>%
  map(dplyr::bind_rows, .id = "table_num") %>%
  dplyr::bind_rows(.id = "html_file") %>%
  dplyr::mutate(html_file = stringr::str_replace(html_file, "downloaded_html/datalist-", ""))


# confirm colnames are expected
identical(colnames(zokusei_tables), c("html_file", "table_num", "属性名", "説明", "属性の型"))
identical(colnames(chibutsu_tables), c("html_file", "table_num", "地物名", "説明"))

# confirm there are no other tables
result %>%
  map(discard, ~ ncol(.) %in% c(2L, 3L)) %>% 
  flatten

# write
readr::write_csv(zokusei_tables, path = "zokusei.csv")
readr::write_csv(chibutsu_tables, path = "chibutsu.csv")
```

### Update the list of code description URLs

```r
KSJCodesDescriptionURL <- extract_all_codelist_urls()
devtools::use_data(KSJCodesDescriptionURL, overwrite = TRUE)
file.copy("data/KSJCodesDescriptionURL.rda", "/path/to/kokudosuuchi/data/", overwrite = TRUE)
```

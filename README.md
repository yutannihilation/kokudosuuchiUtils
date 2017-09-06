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

### Extract codes and names from `zokusei_tables`

```r
library(dplyr)
library(kokudosuuchiUtils)

zokusei_table <- readr::read_csv("zokusei.csv")

d <- KSJIdentifierDescriptionURL %>%
  mutate(html_file = basename(.data$url)) %>% 
  inner_join(zokusei_table, by = "html_file") %>%
  select(identifier,
         table_num,
         attributes = 属性名,
         type = 属性の型)

## workaround for https://github.com/yutannihilation/kokudosuuchiUtils/issues/3#issuecomment-327374894
index_double_code <- which(d$attributes == "設置期間（設置開始）(N05_005b)設置期間（設置終了）(N05_005e)")
row_double_code <- d[765,] %>%
  mutate(attributes = stringr::str_split(attributes, "(?<!^)(?=設置期間)")) %>%
  tidyr::unnest(attributes)
d <- bind_rows(d[1:764, ],
               row_double_code,
               d[766:nrow(d), ])

linebreak_pattern <- "\\s*[\\n\\r]+\\s*"
comment_pattern <- "(?<=[\\)）])[^\\(（]+$"

d <- d %>%
  # remove unneeded rows
  filter(!is.na(.data$type)) %>% 
  mutate(attributes = stringr::str_replace_all(.data$attributes, linebreak_pattern, "")) %>%
  # extract comments
  mutate(note = stringr::str_extract(.data$attributes, comment_pattern),
         attributes = stringr::str_replace(.data$attributes, comment_pattern, "")) %>%
  # extract code
  tidyr::extract(attributes,
                 into = c("name", "code"),
                 regex = "^(.*?)([（\\(][A-Z][^）\\)]+[）\\)])?$") %>%
  mutate(code = stringr::str_replace_all(code, "[（\\(）\\)\\*※]", "")) 

readr::write_csv(d, "codes.csv")
```


### Update the list of code description URLs

```r
KSJCodesDescriptionURL <- extract_all_codelist_urls()
devtools::use_data(KSJCodesDescriptionURL, overwrite = TRUE)
file.copy("data/KSJCodesDescriptionURL.rda", "/path/to/kokudosuuchi/data/", overwrite = TRUE)
```

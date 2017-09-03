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
map(datalist_files, read_kokudosuuchi_table)
```

### Update the list of code description URLs

```r
KSJCodesDescriptionURL <- extract_all_codelist_urls()
devtools::use_data(KSJCodesDescriptionURL, overwrite = TRUE)
file.copy("data/KSJCodesDescriptionURL.rda", "/path/to/kokudosuuchi/data/", overwrite = TRUE)
```

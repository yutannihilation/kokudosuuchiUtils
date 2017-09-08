# kokudosuuchiUtils

[![Travis-CI Build Status](https://travis-ci.org/yutannihilation/kokudosuuchiUtils.svg?branch=master)](https://travis-ci.org/yutannihilation/kokudosuuchiUtils)

## Installation

``` r
# install.packages("devtools")
devtools::install_github("yutannihilation/kokudosuuchiUtils")
```
## Procedures

### Update the list of data description URLs

See [Fetch description URLs](docs/fetch-description-url.Rmd)

### Parse all data description HTMLs

See [Parse all data description HTMLs](docs/parse-all-description-html.Rmd)

### Update the list of codes from `shape_property_table.xls`

See [Fetch shape_property_table.xls](docs/fetch-shape-property-table-xls.Rmd)

### Merge HTML data and Excel data

See [Merge HTML Data And Excel Data](docs/merge-html-data-and-excel-data.Rmd)

### Update the list of code description URLs

```r
KSJCodesDescriptionURL <- extract_all_codelist_urls()
devtools::use_data(KSJCodesDescriptionURL, overwrite = TRUE)
file.copy("data/KSJCodesDescriptionURL.rda", "/path/to/kokudosuuchi/data/", overwrite = TRUE)
```

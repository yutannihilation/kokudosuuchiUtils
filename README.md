# kokudosuuchiUtils

[![CircleCI](https://circleci.com/gh/yutannihilation/kokudosuuchiUtils.svg?style=svg)](https://circleci.com/gh/yutannihilation/kokudosuuchiUtils)
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

### Update the list of code description URLs

```r
KSJCodesDescriptionURL <- extract_all_codelist_urls()
devtools::use_data(KSJCodesDescriptionURL, overwrite = TRUE)
file.copy("data/KSJCodesDescriptionURL.rda", "/path/to/kokudosuuchi/data/", overwrite = TRUE)
```

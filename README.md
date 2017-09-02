# kokudosuuchiUtils

[![CircleCI](https://circleci.com/gh/yutannihilation/kokudosuuchiUtils.svg?style=svg)](https://circleci.com/gh/yutannihilation/kokudosuuchiUtils)

## Installation

``` r
# install.packages("devtools")
devtools::install_github("yutannihilation/kokudosuuchiUtils")
```
## Procedures

### Update list of description URLs

```r
description_urls <- fetch_description_urls()
devtools::use_data(description_urls, overwrite = TRUE)
```

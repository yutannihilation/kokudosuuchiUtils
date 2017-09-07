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
indices_double_code <- d$attributes == "設置期間（設置開始）(N05_005b)設置期間（設置終了）(N05_005e)"
d_part_double_code <- d[indices_double_code, ] %>%
  mutate(attributes = stringr::str_split(attributes, "(?<!^)(?=設置期間)")) %>%
  tidyr::unnest(attributes)

d <- bind_rows(d[!indices_double_code, ],
               d_part_double_code)

linebreak_pattern <- "\\s*[\\n\\r]+\\s*"
comment_pattern <- "(?<=[\\)）])[^\\(（]+$"

d <- d %>%
  # remove unneeded rows
  filter(!is.na(.data$type)) %>% 
  mutate(attributes = stringr::str_replace_all(.data$attributes, linebreak_pattern, "")) %>%
  # insert separators
  mutate(attributes = stringr::str_replace(.data$attributes,
                                           "([\\(（][A-Z][0-9a-z\\-]+[\\*※]?[_\\-][A-Za-z0-9\\-_ 〜]+[\\)）])", 
                                           "%NINJA%\\1%NINJA%")) %>%
  # separate by the separators
  tidyr::separate(col = attributes,
                  into = c("name", "code", "note"),
                  sep = "%NINJA%",
                  fill = "right") %>%
  # clean up codes
  mutate(code = stringr::str_replace_all(code, "[（\\(）\\)\\*※]", ""),
         note = stringr::str_trim(note),
         note = dplyr::if_else(note == "", NA_character_, note))

indices_tilda <- dplyr::coalesce(stringr::str_detect(d$code, "〜"), FALSE)
indices_XX <- dplyr::coalesce(stringr::str_detect(d$code, "(?<=[^X])XX$"), FALSE)
indices_XXXX <- dplyr::coalesce(stringr::str_detect(d$code, "(?<=[^X])XXXX$"), FALSE)

# extract tilda
d_part_tilda <- d[indices_tilda, ] %>%
  # trim numbers (this cannot matched)
  mutate(name = stringr::str_replace(.data$name, "（?\\d+[\\-〜][\\dn]+）?", "")) %>% 
  tidyr::separate(code, into = c("prefix", "begin", "end"), regex = "_|〜", fill = "right") %>%
  mutate_at(c("begin", "end"), funs(readr::parse_integer)) %>%
  mutate(end = dplyr::coalesce(.data$end, 30L)) %>% 
  mutate(code = purrr::pmap(., function(prefix, begin, end, ...) sprintf("%s_%03d", prefix, seq(begin, end)))) %>%
  tidyr::unnest(code) %>%
  group_by(identifier) %>%
  mutate(name = paste0(name, row_number())) %>%
  select(-(prefix:end))

# XX can be ignored as they are layer names. XXXX should be treated specially, but not here.
d <- bind_rows(d[!(indices_tilda | indices_XX | indices_XXXX), ], d_part_tilda)

readr::write_csv(d, "codes.csv")
```


### Update the list of code description URLs

```r
KSJCodesDescriptionURL <- extract_all_codelist_urls()
devtools::use_data(KSJCodesDescriptionURL, overwrite = TRUE)
file.copy("data/KSJCodesDescriptionURL.rda", "/path/to/kokudosuuchi/data/", overwrite = TRUE)
```

Extract Attribute Names And Codes
=================================

属性名 can be the following pattern:

```r
d <- data.frame(
  x = c(
    "都市基盤1",                                           # name, no code
    "土砂災害危険箇所（面）",                              # name with full-width parenthesis, no code
    "観測点名（A22_000001）",                              # name, and code with full-width parenthesis
    "都道府県名(A29_002)",                                 # name, and code with half-width parenthesis
    "各年度別最深積雪（平均値）（A22_010001）",            # name with full-width parenthesis, and code with full-width parenthesis
    "空間属性（メッシュ）(A30a5_010)",                     # name with full-width parenthesis, and code with half-width parenthesis
    "設置期間(終了年)（N08_023）",                         # name with half-width parenthesis, and code with full-width parenthesis
    "各年度別最深積雪（A22_01XXXX）XXXX：西暦",            # name and code and note
    "雪害（A22-m-14_SnowDisaster_XX）XX:都道府県コード",   # name and a bit complecated code and note
    "行政区域（P22*_001）",                                # name and code with frill
    "構成資産範囲ID(A34※_001)※シェープファイルのみ"      # name and code with frill and note
  ),
  stringsAsFactors = FALSE
)
```

It is very difficult to extract name, code, and note at once, due to constraints of regular expressions; we have to take the following steps.

Step 0. Clean up data
---------------------

(This step is not needed for the example data above, though)

```r
d %>%
  # remove unneeded rows
  filter(!is.na(.data$type)) %>% 
  # remove line breaks
  mutate(attributes = stringr::str_replace_all(.data$attributes, "\\s*[\\n\\r]+\\s*", ""))
```

Step 1. Extract notes
---------------------

Notes can be extracted by the following regex

```r
stringr::str_extract(d$x, "(?<=[\\)）])[^\\(（]+$")
#>  [1] NA                       NA                       NA                      
#>  [4] NA                       NA                       NA                      
#>  [7] NA                       "XXXX：西暦"             "XX:都道府県コード"     
#> [10] NA                       "※シェープファイルのみ"
```

So, extract it and remove it.

```r
d <- dplyr::mutate(d,
                   note = stringr::str_extract(.data$x, "(?<=[\\)）])[^\\(（]+$"),
                   x    = stringr::str_replace(.data$x, "(?<=[\\)）])[^\\(（]+$", ""))
```

Step 2. Extract names and codes
-------------------------------

```r
d <- tidyr::extract(d,
                    col = x,
                    into = c("name", "code"),
                    regex = "^(.*?)([（\\(][A-Z][^）\\)]+[）\\)])?$") 
#>                          name                         code
#> 1                   都市基盤1                         <NA>
#> 2      土砂災害危険箇所（面）                         <NA>
#> 3                    観測点名               （A22_000001）
#> 4                  都道府県名                    (A29_002)
#> 5  各年度別最深積雪（平均値）               （A22_010001）
#> 6        空間属性（メッシュ）                  (A30a5_010)
#> 7            設置期間(終了年)                  （N08_023）
#> 8            各年度別最深積雪               （A22_01XXXX）
#> 9                        雪害 （A22-m-14_SnowDisaster_XX）
#> 10                   行政区域                 （P22*_001）
#> 11             構成資産範囲ID                  (A34※_001)
#>                      note
#> 1                    <NA>
#> 2                    <NA>
#> 3                    <NA>
#> 4                    <NA>
#> 5                    <NA>
#> 6                    <NA>
#> 7                    <NA>
#> 8              XXXX：西暦
#> 9       XX:都道府県コード
#> 10                   <NA>
#> 11 ※シェープファイルのみ
```

Step 3. Clean up codes
----------------------

Remove parenthesis and astarisk.

```r
dplyr::mutate(d, code = stringr::str_replace_all(code, "[（\\(）\\)\\*※]", "")) 
#>                          name                     code                   note
#> 1                   都市基盤1                     <NA>                   <NA>
#> 2      土砂災害危険箇所（面）                     <NA>                   <NA>
#> 3                    観測点名               A22_000001                   <NA>
#> 4                  都道府県名                  A29_002                   <NA>
#> 5  各年度別最深積雪（平均値）               A22_010001                   <NA>
#> 6        空間属性（メッシュ）                A30a5_010                   <NA>
#> 7            設置期間(終了年)                  N08_023                   <NA>
#> 8            各年度別最深積雪               A22_01XXXX             XXXX：西暦
#> 9                        雪害 A22-m-14_SnowDisaster_XX      XX:都道府県コード
#> 10                   行政区域                  P22_001                   <NA>
#> 11             構成資産範囲ID                  A34_001 ※シェープファイルのみ
```

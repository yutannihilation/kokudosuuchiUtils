Extract Attribute Names And Codes
=================================

(A lot thanks to this tweet!: https://twitter.com/f_nisihara/status/905768318757306370)

属性名 can be the following pattern:

```r
d <- data.frame(
  x = c(
    "都市基盤1",                                        # name, no code
    "土砂災害危険箇所（面）",                             # name with full-width parenthesis, no code
    "観測点名（A22_000001）",                           # name, and code with full-width parenthesis
    "都道府県名(A29_002)",                              # name, and code with half-width parenthesis
    "各年度別最深積雪（平均値）（A22_010001）",            # name with full-width parenthesis, and code with full-width parenthesis
    "空間属性（メッシュ）(A30a5_010)",                     # name with full-width parenthesis, and code with half-width parenthesis
    "設置期間(終了年)（N08_023）",                       # name with half-width parenthesis, and code with full-width parenthesis
    "各年度別最深積雪（A22_01XXXX）XXXX：西暦",           # name and code and note
    "雪害（A22-m-14_SnowDisaster_XX）XX:都道府県コード",   # name and a bit complecated code and note
    "行政区域（P22*_001）",                             # name and code with frill
    "構成資産範囲ID(A34※_001)※シェープファイルのみ"           # name and code with frill and note
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

Step 1. Insert separators
-------------------------

```r
d <- dplyr::mutate(d,
                   x  = stringr::str_replace(.data$x, "([\\(（][A-Za-z0-9※_\\-\\*]+[\\)）])", "%NINJA%\\1%NINJA%"))

d
#>                                                                  x
#> 1                                                        都市基盤1
#> 2                                           土砂災害危険箇所（面）
#> 3                             観測点名%NINJA%（A22_000001）%NINJA%
#> 4                                都道府県名%NINJA%(A29_002)%NINJA%
#> 5           各年度別最深積雪（平均値）%NINJA%（A22_010001）%NINJA%
#> 6                    空間属性（メッシュ）%NINJA%(A30a5_010)%NINJA%
#> 7                        設置期間(終了年)%NINJA%（N08_023）%NINJA%
#> 8           各年度別最深積雪%NINJA%（A22_01XXXX）%NINJA%XXXX：西暦
#> 9  雪害%NINJA%（A22-m-14_SnowDisaster_XX）%NINJA%XX:都道府県コード
#> 10                              行政区域%NINJA%（P22*_001）%NINJA%
#> 11   構成資産範囲ID%NINJA%(A34※_001)%NINJA%※シェープファイルのみ
```

Step 2. Separate by the separateors
-----------------------------------

```r
d <- tidyr::separate(d,
                     col = x,
                     into = c("name", "code", "note"),
                     sep = "%NINJA%",
                     fill = "right")

d
#>                          name                         code                   note
#> 1                        <NA>                         <NA>              都市基盤1
#> 2                        <NA>                         <NA> 土砂災害危険箇所（面）
#> 3                    観測点名               （A22_000001）                       
#> 4                  都道府県名                    (A29_002)                       
#> 5  各年度別最深積雪（平均値）               （A22_010001）                       
#> 6        空間属性（メッシュ）                  (A30a5_010)                       
#> 7            設置期間(終了年)                  （N08_023）                       
#> 8            各年度別最深積雪               （A22_01XXXX）             XXXX：西暦
#> 9                        雪害 （A22-m-14_SnowDisaster_XX）      XX:都道府県コード
#> 10                   行政区域                 （P22*_001）                       
#> 11             構成資産範囲ID                  (A34※_001) ※シェープファイルのみ
```

Step 3. Clean up codes and notes
--------------------------------

Remove parenthesis and astarisk. Replace empty note with NA.

```r
d <- dplyr::mutate(d,
                   code = stringr::str_replace_all(code, "[（\\(）\\)\\*※]", ""),
                   note = stringr::str_trim(note),
                   note = dplyr::if_else(note == "", NA_character_, note))

d
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

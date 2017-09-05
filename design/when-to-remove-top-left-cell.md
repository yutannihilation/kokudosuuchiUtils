When (And When Not To) Remove Top-left Corner Cells
===================================================

Kokudosuuchi tables are categolized as follows:

**1) The top-left header cell is vertically long**

```
+----------+--------+-----
|          | 属性名 | ...
+          +--------+-----
|          | 項目1  | ...
| 属性情報 +--------+-----
|          | 項目2  | ...
```

**2) The top-left header cell is NOT vertically long**

**2-1) The second-top left cell is vertically long and labelled as "属性情報"**

```
+----------+--------+-----
| 属性情報 | 属性名 | ...
+----------+--------+-----
|          | 項目1  | ...
|          +--------+-----
| 属性情報 | 項目2  | ...
```

**2-2) The second-top left cell is vertically long and labelled nothing**

``` 
+----------+--------+-----
| 属性情報 | 属性名 | ...
+----------+--------+-----
|          | 項目1  | ...
|          +--------+-----
|          | 項目2  | ...
```

**2-2) The second-top left cell is vertically long and labelled wrongly**

```
+----------+--------+-----
| 属性情報 | 属性名 | ...
+----------+--------+-----
|          | 項目1  | ...
|          +--------+-----
| 謎ラベル | 項目2  | ...
```

But we have to careful that in the following case, we cannot remove the top-left cell:

**3) The vertically long cell is overwrapped on the next table**

```
+----------+--------+-----  <------- start of table 1
|          | 属性名 | ...
+          +--------+-----
|          | 項目1  | ...
| 属性情報 +--------+-----
|          | 項目2  | ...
    ...      ...      
+          +--------+-----  <------- start of table 2
|          | 属性名 | ...
+          +--------+-----
|          | 項目1  | ...
```

If we extract the second table only, it will look like this:

```
+--------+-----
| 属性名 | ...
+--------+-----
| 項目1  | ...
+--------+-----
| 項目2  | ...
```

In this situation, we cannot remove the top-left cell.

Conclusion
----------

* If the header's leftmost cell has bgcolor and rowspan attribute, remove it and do nothing about the content rows.
* If the header's leftmost cell has bgcolor but doesn't have rowspan attribute,
  - if the content's left-top cell has bgcolor, remove them both.
  - if the content's left-top cell doesn't have bgcolor, do not remove it.


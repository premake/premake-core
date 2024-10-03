Merge two lists into an array of objects containing pairs of values, one from each list.


```lua
table.fold(arr1, arr2)
```

### Parameters ###

`arr1` and `arr2` are tables containing indexed values.


### Return Value ###

A new array of objects containing the corresponding elements from each list.

### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
-- returns { {"A","X"}, {"B","Y"}, {"C","Z"} }
table.fold({ "A", "B", "C" }, { "X", "Y", "Z" })

-- returns { {"A","X"}, {"B","Y"}, {"C"} }
table.fold({ "A", "B", "C" }, { "X", "Y" })
```

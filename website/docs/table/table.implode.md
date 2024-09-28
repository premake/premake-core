Merges an array of items into a single, formatted string.

```lua
table.implode(arr, "before", "after", "between")
```

### Parameters ###

`arr` is the array to be converted into a string. `before` is a string to be inserted before each item. `after` is a string to be inserted after each item. `between` is a string to be inserted between items.


### Return Value ###

The formatted string.


### Availability ###

Premake 4.0 or later.


### Examples ###

```lua
-- returns "[A],[B],[C]"
table.implode({ "A", "B", "C"}, "[", "]", ",")
```

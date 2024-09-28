Translates the values contained in array, using the specified translation table, and returns the results in a new array.

```lua
table.translate(arr, translation)
```

### Parameters ###

`arr` is the array of values to be translated. *translation* is a key-value table containing the replacement values, or a function taking a single value and returning the translation.


### Return Value ###

Returns a new array containing the translated values.


### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
-- returns { "X", "Y" }
table.translate({ "A", "B", "C"}, { A = "X", C = "Y"})

-- returns { 2, 3, 4 }
table.translate({ 1, 2, 3}, function(value) return value + 1 end)
```

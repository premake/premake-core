Returns the key or index of a value within a table.

```lua
table.indexof(arr, value, cmp)
```

### Parameters ###

`arr` is a table containing indexed elements. `value` is the value for which to search.
`cmp` is a predicate to compare elements, default to `function(lhs, rhs) return lhs == rhs end`

### Return Value ###

The key or index of the value if it is present in the table; nil otherwise.


### Availability ###

Premake 5.0 or later.

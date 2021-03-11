Inserts a value of array of values into a table. If the value is itself a table, its contents are enumerated and added instead.

```lua
table.insertflat(arr, values)
```

### Parameters ###

`arr` is a table containing indexed elements. `values` is a value or array of values to insert.


### Return Value ###

Returns `arr` with the new values added in place.


### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
-- returns { "x", "y" }
table.insertflat({ "x" }, "y")

-- returns { "x", "y", "z" }
table.insertflat({ "x" }, { "y", { "z" } })
```

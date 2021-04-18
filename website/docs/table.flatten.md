Flattens a hierarchy of arrays into a single array containing all of the values.

```lua
table.flatten(arr)
```

### Parameters ###

`arr` is an table containing indexed values, which may themselves also contain indexed values.


### Return Value ###

A new array containing all of the elements, nested or otherwise.


### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
-- returns { "A", "B", "C", "D" }
flat = table.flatten { "A", { "B", "C", { "D" } } }
```

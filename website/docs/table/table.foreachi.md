Walk the elements of an array and call the specified function for each non-nil element.

```lua
table.foreachi(arr, fn)
```

### Parameters ###

`arr` is an table containing indexed values. `fn` is the function to call for each non-nil element. The value (not the index) will be passed as the only argument.


### Return Value ###

None.


### Availability ###

Premake 5.0 or later.

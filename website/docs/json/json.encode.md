Encodes a table to JSON.

```lua
result, err = json.encode(tbl)
```

### Parameters ###

`tbl` is the table to encode.


### Return Value ###

`result` is the resulting string, or `nil` on failure

`err` is the error message if there is one available, always set to `nil` on success


### Availability ###

Premake 5.0 or later.


### See Also ###

* [json.decode](json.decode.md)

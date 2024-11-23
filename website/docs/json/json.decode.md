Decodes a JSON string into a table.

```lua
result, err = json.decode("s")
```

### Parameters ###

`s` is the string to decode.


### Return Value ###

`result` is the resulting table, or `nil` on failure

`err` is the error message if there is one available, always set to `nil` on success


### Availability ###

Premake 5.0 or later.


### See Also ###

* [json.encode](json.encode.md)

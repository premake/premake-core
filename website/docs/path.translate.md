Converts the file separators in a path.

```lua
path.translate("path", "newsep")
```

### Parameters ###

`path` is the file system path to translate; `newsep` is the new path separator. If `newsep` is not specified a Windows-style backslash is assumed.


### Return Value ###

The translated path.


### Availability ###

Premake 4.0 or later.

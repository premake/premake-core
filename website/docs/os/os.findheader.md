Scan the well-known system locations looking for a header file.

```lua
p = os.findheader("headerfile" [, additionalpaths])
```

### Parameters ###

`headerfile` is a file name of a file path to locate.

`additionalpaths` is a string or a table of one or more additional search path. The paths may be absolute or relative. If the path is a relative path, it is relative to each of the default search paths.

### Return Value ###

The path containing the header file, if found. Otherwise, nil.

### Example ###

``` lua
os.findheader("event.h") -- /usr/include
os.findheader("ft2build.h", "freetype2") -- /usr/include/freetype2
```

### Remarks ###
`os.findheader` mostly use the same paths as [[os.findlib]] but replace `/lib` by `/include`.

### Availability ###

Premake 5.0 or later.

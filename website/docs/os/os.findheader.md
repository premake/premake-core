Scan the well-known system locations looking for a header file.

```lua
p = os.findheader("headerfile" [, additionalpaths])
```

### Parameters ###

`headerfile` is a file name or a the end of a file path to locate.

`additionalpaths` is a string or a table of one or more additional search path. Absolute paths are searched directly; relative paths are treated as is, relative to the current working directory.

### Return Value ###

The path containing the header file, if found. Otherwise, nil.

### Example ###

``` lua
os.findheader("stdlib.h")              -- e.g. /usr/include
os.findheader("freetype2/ft2build.h")  -- e.g. /usr/include
os.findheader("ft2build.h", {"/usr/local/include/freetype2", "/usr/include/freetype2"})  -- e.g. /usr/include/freetype2
```

### Remarks ###
`os.findheader` mostly use the same paths as [[os.findlib]] but replace `/lib` by `/include`.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [os.findsubdirheader](os.findsubdirheader.md)
* [os.findlib](os.findlib.md)

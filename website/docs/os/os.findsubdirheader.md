Scan the well-known system locations looking for a header file, with support for subdirectory paths.

```lua
p = os.findsubdirheader("headerfile", additionalpaths)
```

### Parameters ###

`headerfile` is a file name or the end of a file path to locate.

`additionalpaths` is a required string or table of one or more subdirectory paths:

- **Relative paths** are joined with every default include search path (cross-join); only the resulting subdirectories are searched.
- **Absolute paths** are searched directly, acting the same behaviour of [[os.findheader]].
- **Empty string `""`** is treated as a path segment that resolves to the base include path itself, so it can be mixed with other entries (e.g. `{"freetype2", ""}` searches both `<base>/freetype2` and `<base>`).

### Return Value ###

The path containing the header file, if found. Otherwise, nil.

### Example ###

``` lua
os.findsubdirheader("ft2build.h", "freetype2")                   -- e.g. /usr/include/freetype2
os.findsubdirheader("gl.h", {"OpenGL", "GL"})                    -- e.g. /usr/include/GL
os.findsubdirheader("ft2build.h", "/your/path/to/freetype2")     -- e.g. /your/path/to/freetype2
```

### Remarks ###
Unlike [[os.findheader]], relative paths in `additionalpaths` are resolved against each default search path, allowing discovery of headers in named subdirectories without requiring an absolute path. **Only** the specified subdirectories are searched, unless `additionalpaths` contains an empty string.

`os.findsubdirheader` uses the same base paths as [[os.findheader]], which mostly uses the same paths as [[os.findlib]] but replace `/lib` by `/include`.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [os.findheader](os.findheader.md)
* [os.findlib](os.findlib.md)

Scan the well-known system locations looking for a library file.

```lua
p = os.findlib("libname" [, additionalpaths])
```

### Parameters ###

`libname` is name of the library to locate. It may be specified with (libX11.so.md) or without (X11) system-specific decorations.

`additionalpaths` is a string or a table of one or more additional search path
### Return Value ###

The path containing the library file, if found. Otherwise, nil.


### Availability ###

Premake 4.0 or later.

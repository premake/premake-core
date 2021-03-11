Specifies the import library file extension. Import libraries are generated for Windows DLL projects.

```lua
implibextension ("ext")
```

By default, the toolset static library file extension will be used (`.lib` with Windows tools, `.a` with GNU tools). The `implibextension` function allows you to change this default.

### Parameters ###

`ext` is the new file extension, including the leading dot.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
implibextension ".mpi"
```

### See Also ###

 * [implibname](implibname.md)
 * [implibdir](implibdir.md)
 * [implibprefix](implibprefix.md)
 * [implibsuffix](implibsuffix.md)


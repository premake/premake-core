Specifies the import library output directory. Import libraries are generated for Windows DLL projects.

```lua
implibdir ("path")
```

By default, the generated project files will place the import library in the same directory as the compiled binary. The `implibdir` function allows you to change this location.

### Parameters ###

`path` is the output directory for the library, relative to the currently executing script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
implibdir "../Libraries"
```

### See Also ###

 * [implibname](implibname.md)
 * [implibextension](implibextension.md)
 * [implibprefix](implibprefix.md)
 * [implibsuffix](implibsuffix.md)

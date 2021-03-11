Specifies the file extension for the compiled binary target.

```lua
targetextension ("ext")
```

By default, the project will use the system's normal naming conventions: .exe for Windows executables, .so for Linux shared libraries, and so on. The `targetextension` function allows you to change this default.

### Parameters ###

`ext` is the new file extension, including the leading dot.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
targetextension ".zmf"
```

### See Also ###

 * [targetname](targetname.md)
 * [targetdir](targetdir.md)
 * [targetprefix](targetprefix.md)
 * [targetsuffix](targetsuffix.md)

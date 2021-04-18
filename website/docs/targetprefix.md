Specifies the file name prefix for the compiled binary target.

```lua
targetprefix ("prefix")
```

By default, the system naming convention will be used: a "lib" prefix for POSIX libraries (as in `libMyProject.so`), and no prefix elsewhere. The `targetprefix` function allows you to change this default.

### Parameters ###

`prefix` is the new file name prefix.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
targetprefix "plugin"
```

The prefix may also be set to an empty string for no prefix.

```lua
targetprefix ""
```

### See Also ###

 * [targetname](targetname.md)
 * [targetdir](targetdir.md)
 * [targetextension](targetextension.md)
 * [targetsuffix](targetsuffix.md)

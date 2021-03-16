Specifies the import library file name prefix. Import libraries are generated for Windows DLL projects.

```lua
implibprefix ("prefix")
```

By default, the system naming convention will be used: no prefix on Windows, a prefix of `lib` (as in `libMyProject.a`) on other systems. The `implibprefix` function allows you to change this default.

### Parameters ###

`prefix` is the new file name prefix.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
implibprefix "plugin"
```

The prefix may also be set to an empty string for no prefix.

```lua
implibprefix ""
```

### See Also ###

 * [implibname](implibname.md)
 * [implibdir](implibdir.md)
 * [implibextension](implibextension.md)
 * [implibsuffix](implibsuffix.md)

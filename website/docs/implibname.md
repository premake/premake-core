Specifies the import library base file name. Import libraries are generated for Windows DLL projects.

```lua
implibname ("name")
```

By default, the target name will be used as the import library file name. The `implibname` function allows you to change this default.

### Parameters ###

`name` is the new base file name.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
implibname "mytarget"
```

### See Also ###

 * [implibdir](implibdir.md)
 * [implibextension](implibextension.md)
 * [implibprefix](implibprefix.md)
 * [implibsuffix](implibsuffix.md)

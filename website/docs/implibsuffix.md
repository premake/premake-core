Specifies a file name suffix for the import library base file name. Import libraries are generated for Windows DLL projects.

```lua
implibsuffix ("suffix")
```

### Parameters ###

`suffix` is the new filename suffix.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
-- Add "-d" to debug versions of files
filter { "configurations:Debug" }
   implibsuffix "-d"
```

### See Also ###

 * [implibname](implibname.md)
 * [implibdir](implibdir.md)
 * [implibextension](implibextension.md)
 * [implibprefix](implibprefix.md)

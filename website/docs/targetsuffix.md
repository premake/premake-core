Specifies a file name suffix for the compiled binary target.

```lua
targetsuffix ("suffix")
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
   targetsuffix "-d"
```

### See Also ###

 * [targetname](targetname.md)
 * [targetdir](targetdir.md)
 * [targetextension](targetextension.md)
 * [targetprefix](targetprefix.md)

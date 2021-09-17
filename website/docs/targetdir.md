Sets the destination directory for the compiled binary target.

```lua
targetdir ("path")
```

By default, the generated project files will place their compiled output in the same directory as the script. The `targetdir` function allows you to change this location.

### Parameters ###

`path` is the file system path to the directory where the compiled target file should be stored. It is specified relative to the currently executing script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

This project separates its compiled output by configuration type.

```lua
project "MyProject"

  filter { "configurations:Debug" }
    targetdir "bin/debug"

  filter { "configurations:Release" }
    targetdir "bin/release"
```

### See Also ###

 * [targetname](targetname.md)
 * [targetextension](targetextension.md)
 * [targetprefix](targetprefix.md)
 * [targetsuffix](targetsuffix.md)

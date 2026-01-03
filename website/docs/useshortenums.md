Specifies if short enums should be used.

```lua
useshortenums ("value")
```

If no value is set for a configuration, the toolset's default option will be used.

### Parameters ###

`value` specifies the desired wpf setting:

| Value      | Description                                       | Notes |
|------------|---------------------------------------------------|
| Default    | Use the default behavior                          |
| On         | Enums are backed by the smallest legal integral.  | Binaries compiled with short enums may not be ABI compatible with those without. It is recommended to compile all projects with the same setting. |
| Off        | Enums are backed by the default integral.         |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later for Android projects in Visual Studio or any GCC/Clang project.

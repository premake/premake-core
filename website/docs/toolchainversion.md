Specifies the version of the toolchain to use.

```lua
toolchainversion ("value")
```

### Parameters ###

`value` is one of:

### Android Projects ###

| Value | Description |
|-------|-------------|
| 4.6 | GCC 4.6 |
| 4.8 | GCC 4.8 |
| 4.9 | GCC 4.9 |
| 3.4 | Clang 3.4 |
| 3.5 | Clang 3.5 |
| 3.6 | Clang 3.6 |
| 3.8 | Clang 3.8 |
| 5.0 | Clang 5.0 |

### Linux Projects ###

| Value | Description |
|-------|-------------|
| remote | Remote compilation and debugging |
| wsl | Windows Subsystem for Linux |
| wsl2 | Windows Subsystem for Linux 2 |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later, only applies to Android projects.
Premake 5.0.0-beta3 or later, only applies to Visual Studio Linux projects.
Deprecated in 5.0.0-beta8. Use `toolset` API with version instead, such as `toolset 'gcc-4.6'` or `toolset 'clang-wsl2'`.

### Examples ###

```lua
toolchainversion "5.0"
```


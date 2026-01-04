Controls whether a Windows manifest file should be generated for the project.

```lua
manifest ("value")
```

By default, Visual Studio will generate an external manifest file for C/C++ executables.

### Parameters ###

`value` is one of:

| Value       | Description                                                                |
|-------------|----------------------------------------------------------------------------|
| Default     | Use default behavior (manifest is generated)                               |
| On          | Generate manifest file                                                     |
| Off         | Do not generate manifest file                                              |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later.

### Examples ###

Disable manifest generation:

```lua
manifest "Off"
```

Embed the manifest into the binary:

```lua
manifest "Embed"
```

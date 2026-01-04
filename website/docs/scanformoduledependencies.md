Enables the `Scan Sources for Module Dependencies` option for Visual Studio projects.

```lua
scanformoduledependencies ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On | Enable scanning for module dependencies. |
| Off | Disable scanning for module dependencies. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta2 or later for Visual Studio 2019 16.9 and later.

## Examples ##

```lua
scanformoduledependencies "On"
```

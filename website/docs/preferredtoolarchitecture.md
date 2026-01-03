Specifies the preferred architecture to use for the Visual Studio toolchain.

```lua
preferredtoolarchitecture ("value")
```

### Parameters ###

`value` one of:

| Value | Description |
|-------|-------------|
| Default | Use the preferred tool architecture. |
| x86 | Use x86 tooling. |
| x86_64 | Use x86_64 tooling. |

### Applies To ###

Workspace configurations.

### Availability ###

Premake 5.0.0-alpha12 or later for Visual Studio.

### Examples ###

```lua
preferredtoolarchitecture "value"
```


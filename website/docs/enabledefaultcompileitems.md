Specifies if implicitly included C# and language extension files should be compiled. Defaults to `Off`.

```lua
enabledefaultcompileitems ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Enable compilation of implicitly included C# and language extension files. |
| Off   | Disable compilation of implicitly included C# and language extension files. |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha16 or later for Visual Studio C# Projects.

### Examples ###

```lua
enabledefaultcompileitems "Off"
```


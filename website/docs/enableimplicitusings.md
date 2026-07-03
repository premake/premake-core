Specifies if C# implicit usings should be enabled. Defaults to `Off`.

```lua
enableimplicitusings ("value")
```

### Parameters ###

`value` is one of:

| Value   | Description |
|---------|-------------|
| Default | Don't include property for implicit usings |
| On      | Enable C# implicit usings. |
| Off     | Disable C# implicit usings. |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0 or later for Visual Studio C# Projects.

### Examples ###

```lua
enableimplicitusings "On"
```

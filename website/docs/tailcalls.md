Specifies if tailcalls should be enabled in Visual Studio F# projects.

```lua
tailcalls ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Enable tail calls |
| Off   | Disable tail calls |

## Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.0-alpha14 or later for Visual Studio F# Projects.

### Examples ###

```lua
tailcalls "On"
```


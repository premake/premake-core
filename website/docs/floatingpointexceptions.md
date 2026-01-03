Specifies whether or not unmasked floating point exceptions should be raised at the point they occur.

```lua
floatingpointexceptions ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Turn on floating point exceptions |
| Off   | Turn off floating point exceptions |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
floatingpointexceptions "On"
```


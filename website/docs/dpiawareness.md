Sets the DPI awareness settings.

```lua
dpiawareness ("value")
```

### Parameters ###

`value` is one of:

| Value          | Description                                          |
|----------------|------------------------------------------------------|
| Default        | Use the toolset's default setting for DPI awareness. |
| None           | Turn off DPI awareness.                              |
| High           | Turn on DPI awareness.                               |
| HighPerMonitor | Turn on DPI awareness per monitor.                   |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later for Visual Studio.

### Examples ###

```lua
-- Turn on DPI awareness
dpiawareness "High"
```

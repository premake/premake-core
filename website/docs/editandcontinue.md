Turns the edit-and-continue features of a toolset or platform on and off.

```lua
editandcontinue "value"
```

If no value is set for a configuration, the toolset's default setting (usually "On") will be used.

### Parameters ###

`value` is a boolean value, i.e. "On" or "Off".

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
-- Turn off edit and continue
editandcontinue "Off"
```

### See Also ###

- [debugformat](debugformat.md)

Specifies if the binary has edit-and-continue debugging support.

```lua
editandcontinue ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| Default | Uses the default edit-and-continue behavior. |
| On | Allows edit-and-continue behavior of source code while debugging. |
| Off | Disallows edit-and-continue behavior of source code while debugging. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

```lua
-- Turn off edit and continue
editandcontinue "Off"
```

### See Also ###

- [debugformat](debugformat.md)

Specifies whether the code generation uses ARM or Thumb instruction sets.

```lua
thumbmode ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| thumb | Uses Thumb instruction set. |
| arm | Uses ARM instruction set. |
| disabled | Disables Thumb instruction set. |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later.

### Examples ###

```lua
thumbmode "Disabled"
```


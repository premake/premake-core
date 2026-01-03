Force `char` to be unsigned.

```lua
unsignedchar (value)
```

Note that `char` is still a distinct type from `signed char` and `unsigned char`.

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On | Forces `char` to be unsigned. |
| Off | Forces `char` to be signed. |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later.

### Examples ###

```lua
unsignedchar "On"
```

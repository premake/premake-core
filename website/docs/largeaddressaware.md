Specifies to the linker that the 32 bit application can handle addresses larger than 2GB.

```lua
largeaddressaware ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Linker allows handling of addresses greater than 2GB |
| Off   | Linker disallows handling of addresses greater than 2GB |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha12 or later for Visual Studio.

### Examples ###

```lua
largeaddressaware "Off"
```


Specifies to use the 'extended-remote' protocol, which instructs GDB to maintain a persistent connection to gdbserver.

```lua
debugextendedprotocol ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Use `extended-remote` protocol to maintain persistent connection with gdbserver. |
| Off   | Do not use `extended-remote` protocol |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

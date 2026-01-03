Specifies 1, 2, 4, 8, 16-byte boundary for struct member alignment.

```lua
structmemberalign (value)
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| 1 | 1 byte struct member alignment |
| 2 | 2 byte struct member alignment |
| 4 | 4 byte struct member alignment |
| 8 | 8 byte struct member alignment |
| 16 | 16 byte struct member alignment |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later for Visual Studio (non-clang).
Premake 5.0.0-beta7 for others

### Examples ###

```lua
structmemberalign 1
```


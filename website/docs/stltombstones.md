Specifies whether to enable MS STL destructor tombstones.

```lua
stltombstones "value"
```

### Parameters ###

*value* selects the tombstone setting:

| Value   | Description                              |
|---------|------------------------------------------|
| Default | Add no tombstone override.               |
| Off     | Request disabling destructor tombstones. |
| On      | Request enabling destructor tombstones.  |

### Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.1 or later.

### Limitations ###

Requires MS STL from Visual Studio 2022 17.14 or later.

Has no effect with other C++ standard libraries.

### Examples ###

```lua
stltombstones "On"
```

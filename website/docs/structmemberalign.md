structmemberalign - Specifies 1, 2, 4, 8, 16-byte boundary for struct member alignment.

```lua
structmemberalign (value)
```

### Parameters ###

`value` is one of:

* `1`
* `2`
* `4`
* `8`
* `16`

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later for visual studio (non-clang).
Premake 5.0.0 beta 7 for others

### Examples ###

```lua
structmemberalign (1)
```


Specifies whether the code generation uses ARM or Thumb instruction sets.

```lua
thumbmode ("value")
```

### Parameters ###

`value` is one of:

* `thumb`: Uses the Thumb instruction set.
* `arm`: Uses the ARM instruction set.
* `disabled`: Disables usage of Thumb instruction set.

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

```lua
thumbmode "disabled"
```


checkaction - What should happend when an assertion fails (D Lang)


```lua
checkaction (value)
```

### Parameters ###

`value` is one of:

* `Default`: needs documentation
* `D`: call D assert on failure
* `C`: call C assert on failure
* `Halt`: cause program halt on failure
* `Context`: call D assert with the error context on failure

See https://dlang.org/library/dmd/globals/checkaction.html

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 16 or later.

### Examples ###

```lua
checkaction (value)
```


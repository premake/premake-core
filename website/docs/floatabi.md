Specifies the floating point ABI to use.

```lua
floatabi ("value")
```

### Parameters ###

`value` is one of:

* `soft`: Compiler will generate library calls for floating-point operations.
* `softfp`: Compiler will generate code using hardware floating-point instructions, but still uses the soft-float calling conventions.
* `hard`: Compiler will generate floating-point instructions using FPU-specific calling conventions.

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

```lua
floatabi "soft"
```


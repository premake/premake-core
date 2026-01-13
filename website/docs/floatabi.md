Specifies the floating point ABI to use.

```lua
floatabi ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| Soft  | Compiler will generate software library calls for floating-point operations. |
| SoftFP | Compiler will generate hardware floating-point instructions, but will still use software float calling conventions. |
| Hard | Compiler will generate floating-point instructions using FPU-specific calling conventions. |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later.

### Examples ###

```lua
floatabi "soft"
```


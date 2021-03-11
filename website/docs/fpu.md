Specifies whether to generate code for a hardware FPU.

```lua
fpu "value"
```

### Parameters ###

`value` specifies the desired FPU mode:

| Value       | Description                                                       |
|-------------|-------------------------------------------------------------------|
| Software    | Generate software floating-point emulation code.                  |
| Hardware    | Generate code for a hardware FPU.                                 |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [floatingpoint](floatingpoint.md)

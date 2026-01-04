Specifies the shader assembler output.

```lua
shaderassembler ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| NoListing | No generated assembly. |
| AssemblyCode | File containing only generated assembly. |
| AssemblyCodeAndHex | File containing assembly code and corresponding hex code. |

## Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.0-alpha14 or later for Visual Studio.

### Examples ###

```lua
shaderassembler "AssemblyCode"
```


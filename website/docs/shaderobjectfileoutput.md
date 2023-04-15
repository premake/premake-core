Specifies the output object of compiled HLSL files.

```lua
shaderobjectfileoutput ("path")
```

### Parameters ###

`path` is the output path of HLSL files that have been compiled into Compiled Shader Objects.

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

This Visual Studio project will compile HLSL files to the shaders folder with a .cso extension.

```lua
shaderobjectfileoutput "shaders/%%(Filename).cso"
```


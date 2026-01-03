Specifies the shader model.

```lua
shadermodel ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| 2.0 | Shader Model 2.0 |
| 3.0 | Shader Model 3.0 |
| 4.0_level_9_1 | Shader Model 4.0 (Direct3D feature level 9.1) |
| 4.0_level_9_3 | Shader Model 4.0 (Direct3D feature level 9.3) |
| 4.0 | Shader Model 4.0 |
| 4.1 | Shader Model 4.1 |
| 5.0 | Shader Model 5.0 |
| 5.1 | Shader Model 5.1 |
| rootsig_1.0 | Root Signature version 1.0 (Direct3D 12) |
| rootsig_1.1 | Root Signature version 1.1 (Direct3D 12) |
| 6.0 | Shader Model 6.0 |
| 6.1 | Shader Model 6.1 |
| 6.2 | Shader Model 6.2 |
| 6.3 | Shader Model 6.3 |
| 6.4 | Shader Model 6.4 |
| 6.5 | Shader Model 6.5 |
| 6.6 | Shader Model 6.6 |

## Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.0-alpha14 or later for Visual Studio.

### Examples ###

```lua
shadermodel "5.0"
```


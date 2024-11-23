Specifies the shader model.

```lua
shadermodel ("value")
```

### Parameters ###

`value` is one of:

* `2.0`: Shader Model 2.0
* `3.0`: Shader Model 3.0
* `4.0_level_9_1`: Shader Model 4.0 Level 9_1
* `4.0_level_9_3`: Shader Model 4.0 Level 9_3
* `4.0`: Shader Model 4.0
* `4.1`: Shader Model 4.1
* `5.0`: Shader Model 5.0
* `5.1`: Shader Model 5.1
* `rootsig_1.0`: Root Signature Version 1.0
* `rootsig_1.1`: Root Signature Version 1.1
* `6.0`: Shader Model 6.0
* `6.1`: Shader Model 6.1
* `6.2`: Shader Model 6.2
* `6.3`: Shader Model 6.3
* `6.4`: Shader Model 6.4
* `6.5`: Shader Model 6.5
* `6.6`: Shader Model 6.6

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

```lua
shadermodel ("5.0")
```


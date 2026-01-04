Specifies defines to pass to shader compilation.

```lua
shaderdefines { "defines" }
```

### Parameters ###

`defines` is a list of preprocessor definitions to pass to the shader compiler.

## Applies To ###

Project and file configurations

### Availability ###

Premake 5.0.0-alpha14 or later for Visual Studio.

### Examples ###

```lua
shaderdefines { "HELLO_WORLD" }
```


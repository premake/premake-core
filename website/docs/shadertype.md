Specifies the type of shader.

```lua
shadertype ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| Effect | Effect shader |
| Vertex | Vertex shader |
| Pixel | Pixel / fragment shader |
| Geometry | Geometry shader |
| Hull | Hull (tessellation control) shader |
| Domain | Domain (tessellation evaluation) shader |
| Compute | Compute shader |
| Library | Shader library |
| Mesh | Mesh shader |
| Amplification | Amplification shader (task amplification stage) |
| Texture | Texture shader |
| RootSignature | Root signature resource (Direct3D 12 root signature) |

## Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.0-alpha14 or later for Visual Studio.

### Examples ###

```lua
shadertype "Vertex"
```


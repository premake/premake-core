Specifies the type of shader.

```lua
shadertype ("value")
```

### Parameters ###

`value` is one of:

* `Effect`
* `Vertex`
* `Pixel`
* `Geometry`
* `Hull`
* `Domain`
* `Compute`
* `Library`
* `Mesh`
* `Amplification`
* `Texture`
* `RootSignature`

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

```lua
shadertype "Vertex"
```


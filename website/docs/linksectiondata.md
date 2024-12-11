Emit each data item in a separate section. This help linker optimizations to remove unused data.

```lua
linksectiondata("value")
```

### Parameters ###

`value` is one of:

- `On`
- `Off`

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 beta 4 or later for Visual Studio 2022 and later, only applies to Visual Studio Android projects.

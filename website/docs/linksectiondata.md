Emit each data item in a separate section. This help linker optimizations to remove unused data.

```lua
linksectiondata ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Emit individual data items in separate sections. |
| Off   | Do not enable forced separate sections for data items. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta4 or later for Visual Studio 2022 and later, only applies to Visual Studio Android projects.

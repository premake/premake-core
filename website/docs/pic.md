Enable generation of position independent code.

```lua
pic ("value")
```

Position Independent Code is required when building dynamic libraries, or static lib's that will be linked to dynamic libraries. PIC will be enabled by default when building dynamic libraries. It will be disabled by default otherwise.

### Parameters ###

`value` specifies the desired PIC mode:

| Value       | Description                                                       |
|-------------|-------------------------------------------------------------------|
| Off         | Do not generate position independent code.                        |
| On          | Generate position independent code.                               |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1.

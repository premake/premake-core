Enables or disables native wchar (wide character) support by the compiler.

```lua
nativewchar ("value")
```

If no value is set for a configuration, the toolset's default wchar support will be used.

### Parameters ###

`value` specifies the desired state:

| Value       | Description                                            |
|-------------|--------------------------------------------------------|
| Default     | Use the toolset's default settings.                    |
| On          | Enable native wide character handling.                 |
| Off         | Disable native wide character handling.                |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

```lua
nativewchar "Off"
```

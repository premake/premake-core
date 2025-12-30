Specifies whether to omit default libraries when linking.

```lua
nodefaultlib ("value")
```

### Parameters ###

`nodefaultlib` accepts one of the following values:

| Value   | Description                                    |
|---------|------------------------------------------------|
| Default | Use the toolset's default behavior            |
| On      | Omit all default libraries                    |
| Off     | Include default libraries (explicit setting)  |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later.

### Examples ###

Omit all default libraries:

```lua
nodefaultlib "On"
```

Explicitly include default libraries (usually not needed):

```lua
nodefaultlib "Off"
```

### See Also ###

* [ignoredefaultlibraries](ignoredefaultlibraries.md)

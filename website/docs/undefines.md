Removes preprocessor or compiler symbols from a project.

```lua
undefines { "symbols" }
```

If a project includes multiple calls to `undefines` the lists are concatenated, in the order in which they appear in the script.

### Parameters ###

`symbols` specifies a list of symbols to be undefined.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later

### Examples ###

Undefine two symbols in the current project.

```lua
undefines { "DEBUG", "TRACE" }
```

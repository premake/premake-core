Adds preprocessor or compiler symbols to a project.

```lua
defines { "symbols" }
```

### Parameters ###

`symbols` specifies a list of symbols to be defined.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

Define two new symbols in the current project.

```lua
defines { "DEBUG", "TRACE" }
```

Symbols may also assign values.

```lua
defines { "CALLSPEC=__dllexport" }
```

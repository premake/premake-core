Specifies preprocessor symbols for the resource compiler.

```lua
resdefines { "symbols" }
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
resdefines { "DEBUG", "TRACE" }
```

Symbols may also assign values.

```lua
resdefines { "CALLSPEC=__dllexport" }
```
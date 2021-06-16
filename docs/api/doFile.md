# doFile

Load and executes a Lua script file.

```lua
doFile('file', ...)
```

## Parameters

`file` is name of the script file to be executed. See [_PREMAKE.PATH](_PREMAKE.PATH.md) for the list of locations Premake will check to locate this file.

`...` is an optional list of arguments to pass to the script.

## Return Value

If the executed script returns a value, that value will be returned to the called.

## Availability

Premake 6.0 or later (available in base Lua as `dofile`).

## See Also

- [doFileOpt](doFileOpt.md)
- [loadFile](loadFile.md)

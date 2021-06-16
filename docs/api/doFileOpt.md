# doFileOpt

Load and executes a Lua script file. Unlike [doFile](doFile.md), no error is raised if the file is not found.

```lua
doFileOpt('file', ...)
```

## Parameters

`file` is name of the script file to be executed. See [_PREMAKE.PATH](_PREMAKE.PATH.md) for the list of locations Premake will check to locate this file.

`...` is an optional list of arguments to pass to the script.

## Availability

Premake 6.0 or later (available in 5.0 or later as `dofileopt`).

## See Also

- [doFile](doFile.md)
- [loadFile](loadFile.md)

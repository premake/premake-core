Load and executes a Lua script file. Unlike [`doFile()`](doFile.md), no error is raised if the file is not found.


```lua
doFileOpt('file', ...)
```

### Parameters

`file` is name or path of the script file to be executed. See [Locating Scripts](authoring/locating-scripts.md) for the list of locations Premake will check to locate this file.

`...` is an optional list of arguments to pass to the script.

### Return Value

If the executed script returns a value, that value will be returned to the caller.

### Availability

Premake 6.0 or later (available in Premake 5.x as `dofileopt()`).

### See Also

- [`doFile()`](doFile.md)
- [`loadFile()`](loadFile.md)

### Example

```lua
local returnValue = doFileOpt('path/to/script.lua', 'option1', 'option2')
```

The loaded script can access its arguments using Lua's `select()`.

```lua
local option1 = select(1, ...)
local option2 = select(2, ...)
```

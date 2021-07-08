Load a Lua script file.

```lua
chunk = loadFile('file')
```

### Parameters

`file` is name or path of the script file to be executed. See [Locating Scripts](authoring/locating-scripts.md) for the list of locations Premake will check to locate this file.

### Return Value

If successful, returns a function that, when run, executes the contents of the script file. On failure, returns `nil` and an error message.

### Availability

Premake 6.0 or later (available in base Lua as `loadfile()`).

### See Also

- [`doFile()`](doFile.md)

### Example

```lua
local chunk = loadFile('path/to/script.lua')
local returnValue = chunk()
```

---
title: premake.abort
---

Display an error message and immediately end the current Premake execution. Unlike Lua's [`os.exit()`](https://www.lua.org/manual/5.3/manual.html#pdf-os.exit), no stack trace is shown.


```lua
premake.abort(message)
```

### Parameters

`message` is an error messagse to display to the user before exiting.

### Return Value

None.

### Availability

Premake 6.0 or later.

### Examples

```lua
local premake = require('premake')

premake.abort('Error: something went wrong')
```

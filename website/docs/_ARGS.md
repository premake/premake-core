An array of the command line arguments provided to Premake.

### Availability

Premake 6.0 and later.

### Supported Actions

All actions support this feature.

### See Also

- _(options & option processing)_

### Examples

```lua
-- for the command `premake6 vstudio 2019`
local exe = _ARGS[0]     -- "premake6"
local action = _ARGS[2]  -- "vstudio"
local version = _ARGS[3] -- "2019"
```

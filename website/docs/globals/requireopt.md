Require a module or return `false` if module could not be loaded.


```lua
requireopt ("modname", "versions")
```

`requireopt` is an alias of `require(modname, versions, true)`

### Returns ###

* The module on success
* `false`, `error_message` on error

### Examples ###

```
local optionalmodule = require "not-mandatory-but-recommended"
if not optionalmodule
then
	premake.warn ("You will not run this at full power")
end
```

### See Also ###

* [require](require.md)
* [dofileopt](dofileopt.md)

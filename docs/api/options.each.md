# options.each

Iterate each of the valid options present in the current command line arguments. Skips over any arguments which do not match a registered option.

```lua
options = require('options')
for trigger, value in options.each() do ... end
```

## Parameters

None.

## Return Value

A Lua iterator, which returns ordered pairs of registered triggers and values specified on the current command line.

## Availability

Premake 6.0 or later.

## See Also

* [commandLineOption](commandLineOption.md)
* [options.all](options.all.md)
* [options.valueOf](options.valueOf.md)

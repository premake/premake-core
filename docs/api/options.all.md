# options.all

Iterate over all command line arguments, including those that do not match any registered option definition. Will use best guess as to the value of any unregistered options.

```lua
options = require('options')
for trigger, value in options.all() do ... end
```

## Parameters

None.

## Return Value

A Lua iterator, which returns ordered pairs of the triggers and values specified on the current command line.

## Availability

Premake 6.0 or later.

## See Also

* [commandLineOption](commandLineOption.md)
* [options.each](options.each.md)
* [options.valueOf](options.valueOf.md)

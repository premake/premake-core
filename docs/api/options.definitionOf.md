# options.definitionOf

Return the definition associated with specific trigger, as provided to [commandLineOption](commandLineOption.md).


```lua
options = require('options')
def = options.definitionOf('trigger')
```

## Parameters

`trigger` is the trigger value which was provided in the option definition when it was registered.

## Return Value

The option definition with the specified trigger, or `nil` if no such definition exists.

## Availability

Premake 6.0 or later.

## See Also

* [commandLineOption](commandLineOption.md)
* [options.each](options.each.md)
* [options.valueOf](options.valueOf.md)

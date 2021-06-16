# options.execute

Calls the function associated with the specified option, if one exists, passing in the provided value.

```lua
options = require('options')
options.execute('trigger', 'value')
```

## Parameters

`trigger` is the trigger value which was provided in the option definition when it was registered.

`value` is an option value to pass to the option's `execute` function.

## Return Value

None.

## Availability

Premake 6.0 or later.

## See Also

* [commandLineOption](commandLineOption.md)

# options.valueOf

Returns the user-specified value associated with a particular trigger on the current command line, if present. The command line option must have been previously registered using [commandLineOption](commandLineOption.md).

```lua
options = require('options')
value = options.valueOf('trigger')
```

## Parameters

`trigger` is the trigger value which was provided in the option definition when it was registered.

## Return Value

If the trigger is present on the current command line, and the option definition provided to [commandLineOption](commandLineOption.md) specifies that a value is required, the corresponding user-specified value is returned. Otherwise returns `nil`.

## Availability

Premake 6.0 or later.

## See Also

* [commandLineOption](commandLineOption.md)
* [options.each](options.each.md)

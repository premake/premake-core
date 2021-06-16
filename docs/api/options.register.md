# options.register

Registers a new command line option definition.

```lua
options = require('options')
options.register(definition)
```

## Parameters

`definition` is a table describing the new command line option; see [commandLineOption](commandLineOption.md) for a full description.

## Return Value

If successful, returns `true`. If any required fields are missing from the definition, returns `false` and an error message.

## Availability

Premake 6.0 or later.

## See Also

* [commandLineOption](commandLineOption.md)

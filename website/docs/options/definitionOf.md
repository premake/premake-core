---
title: options.definitionOf
---

Return the definition associated with a specific option trigger, as provided to [`commandLineOption()`](commandLineOption.md) or [`option.register()`](register.md).


```lua
definition = options.definitionOf('trigger')
```

### Parameters

`trigger` is the trigger value which was provided in the option definition when it was registered.

### Return Value

The option definition with the specified trigger, or `nil` if no such definition exists.

### Availability

Premake 6.0 or later.

### See Also

* [`commandLineOption()`](../commandLineOption.md)
* [`options.register()`](register.md)
* [`options.valueOf()`](valueOf.md)

---
title: options.all
---

Iterate over all command line arguments, returning trigger-value pairs. If a trigger is encountered which was not previously registered via [`options.register()`](register.md), will use best guess as to option's value.

```lua
for trigger, value in options.all() do ... end
```

### Parameters

None.

### Return Value

A Lua iterator, which returns trigger-value pairs ordered as they appear on the command line.

### Availability

Premake 6.0 or later.

### See Also

- [`options.each()`](each.md)
- [`options.register()`](register.md)
- [`options.valueOf()`](valueOf.md)

### Examples

```lua
local options = require('options')

for trigger, value in options.all() do
	printf('Trigger %s has value "%s"', trigger, value)
end
```

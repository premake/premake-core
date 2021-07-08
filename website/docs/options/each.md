---
title: options.each
---

Iterate each of the registered options present in the current command line arguments, skip any arguments that were not previously registered with [`options.register()`](register.md).

```lua
for trigger, value in options.each() do ... end
```

### Parameters

None.

### Return Value

A Lua iterator, which returns trigger-value pairs ordered as they appear on the command line.

### Availability

Premake 6.0 or later.

### See Also

* [`options.all`](all.md)
* [`options.register`](register.md)
* [`options.valueOf`](valueOf.md)

### Examples

```lua
local options = require('options')

for trigger, value in options.each() do
	printf('Trigger %s has value "%s"', trigger, value)
end
```

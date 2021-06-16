# path.getKind

Determines if the given path is absolute or relative.

```lua
path = require('path')
result = path.getKind('value')
```

## Parameters

`value` is the path to be tested.

## Return Value

One of:

- "absolute" if `value` is an absolute path
- "relative" if `value` is a relative path
- "unknown" if the kind could not be determined; this usually means the path starts with variable of some type

## Availability

Premake 6.0 or later.

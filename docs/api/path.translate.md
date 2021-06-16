# path.translate

Converts the file separators in a path.

```lua
path = require('path')
result = path.translate('value', 'separator')
```

## Parameters

`value` is the path to be translated.

`separator` is the new separator to be used. If not specified, '\\' (backslash; the Windows path separator) is used.

## Return Value

The translated path.

## Availability

Premake 4.0 or later.

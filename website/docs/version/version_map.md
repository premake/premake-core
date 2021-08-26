---
title: Version.map
---

Lookup a value from a table using the current version value.


```lua
version:map(valueMap)
```

### Parameters

`valueMap` is a table with version number keys and associated values. These version keys may use `*` as a wildcard for any portion of the version. If the current version instance was created with a [version map](version_new.md) aliases from the map may be used as well.

### Return Value

The corresponding value from the map if a match is found; `nil` otherwise.

### Availability

Premake 6.0 or later.

### Examples

```lua
local Version = require('version')

version = Version.new('16.4.31429')

-- Returns '16.2'
version:map({
	['17.*.*'] = '17.4',
	['16.*.*'] = '16.2',
	['15.*.*'] = '15.8'
})

-- From the Visual Studio module; looks up value by alias
toolsVersion = vstudio.targetVersion:map({
	['2010'] = '4.0',
	['2012'] = '4.0',
	['2013'] = '12.0',
	['2015'] = '14.0',
	['2017'] = '15.0',
})
```

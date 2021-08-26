---
title: Version.is
---

Tests against a specific version or version pattern.

```lua
version:is('pattern')
```

### Parameters

`pattern` is a version number to test against. This value may use `*` as a wildcard for any portion of the version. If the current version instance was created with a [version map](version_new.md) aliases from the map may be used as well.

### Return Value

True if the versions match; false otherwise.

### Availability

Premake 6.0 or later.

### Examples

```lua
local Version = require('version')

vstudio.VERSIONS = {
	['2022'] = '17.*.*.*',
	['2019'] = '16.*.*.*',
	['2017'] = '15.*.*.*',
	['2015'] = '14.*.*.*',
	['2013'] = '12.*.*.*',
	['2012'] = '11.*.*.*',
	['2010'] = '10.*.*.*'
}

version = Version.new('16.4.31429.391', vstudio.VERSIONS)

-- Returns true
version:is('16.4.31429.391')
version:is('16.*.*.*')
version:is('16.4')
version:is('2019')

-- Returns false
version:is('18.4.9499.40')
version:is('15.5')
version:is('2015')
```

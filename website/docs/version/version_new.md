---
title: Version.new
---

Create a new `Version` instance from a version string and optional version map.

```lua
local version = Version.new('number', map)
```

### Parameters

`number` is a string containing the target version number, ex. `"16.4.31429.391"`. This value may use `*` as a wildcard for any portion of the version.

`map` is an optional table parameter mapping simpler version aliases to full versions; see **Examples** below for an example table. If supplied, this map will be used by methods like
[`is()`](version_is.md) to enable testing against aliases as well as full version numbers.

### Return Value

A new `Version` instance.

### Availability

Premake 6.0 or later.

### See Also

- [`Version.lookup`](version_lookup.md)

### Examples

```lua
local Version = require('version')

-- Versions can be specific or contain wildcards
v = Version.new('16.4.31429.391')
v = Version.new('16.4.*.*')

-- Any portion not specified is considered a wildcard
v = Version.new('16.4')

-- An option version map can be supplied to assign aliases to
-- specific versions, like Visual Studio annual product names
v = Version.new('16.4.31429.391', {
	['2022'] = '17.*.*.*',
	['2019'] = '16.*.*.*',
	['2017'] = '15.*.*.*',
	['2015'] = '14.*.*.*',
	['2013'] = '12.*.*.*',
	['2012'] = '11.*.*.*',
	['2010'] = '10.*.*.*'
})

-- When a version map is supplied, the aliases can be used in
-- any of the version testing methods
if v:is('2019') then ... end
```

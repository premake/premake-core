---
title: Version.lookup
---

Checks a target version against a table of supported version and returns a corresponding `Version` instance.

```lua
local version = Version.lookup('number', map)
```

### Parameters

`number` is a string containing the target version number, ex. `"16.4.31429.391"`. This value may use `*` as a wildcard for any portion of the version. It may also use aliases from the provided version map; see below.

`map` is an table listed the supported version ranges that may be used. Keys for this table can be aliases of "short names" for specific version, ex. "2019" for Visual Studio 2019. If there is no appropriate alias for a particular version then array indexing can be used. Examples are shown below.

### Return Value

A new `Version` instance if a matching supported version range is found in the map; `nil` otherwise.

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

-- Returns version with value '16.4'
v = Version.lookup('16.4', vstudio.VERSIONS)

-- Returns version with value '16.*.*.*'
v = Version.lookup('2019', vstudio.VERSIONS)

-- Returns `nil`
v = Version.lookup('2008', vstudio.VERSIONS)
v = Version.lookup('20.3', vstudio.VERSIONS)

-- If successful, the provided version map is associated with
-- the returned version instance, so you can use the aliases it
-- contains in any tests against that version.
if v:is('2019') then ... end
```

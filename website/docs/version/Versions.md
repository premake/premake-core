---
title: Versions
---

The `version` module adds support for a new `Version` data type, with methods for comparing version and ranges and mapping them to other values. It is used by the exporters to target features to specific toolset versions.

```lua
local Version = require('version)

local targetVersion = Version.new('16.4.31429.391')

if targetVersion:is('16.*.*.*') then ... end

local value = targetVersion:map({
	'16.*.*.*', '2019',
	'15.*.*.*', '2017'
})
```

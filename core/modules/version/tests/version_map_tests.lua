local Version = require('version')

local VersionMapTests = test.declare('VersionMapTests', 'version')


local VERSION_MAP = {
	['2019'] = '16.*.*.*',
	['2017'] = '14.*.*.*'
}


---
-- Should allow matching against wildcards.
---

function VersionMapTests.map_returnsExpectedValue_onWildcardMatch()
	test.isEqual('Value1', Version.new('16.3.4'):map({
		['16.*.*.*'] = 'Value1',
		['14.*.*.*'] = 'Value2'
	}))
end


---
-- Should return `nil` if no match can be found in the map.
---

function VersionMapTests.map_returnsNil_ifNoMatch()
	test.isNil(Version.new('12.3.4'):map({
		['16.*.*.*'] = 'Value1',
		['14.*.*.*'] = 'Value2'
	}))
end


---
-- Is the version was created with a version map it should be valid to
-- test against the aliases contained by that map.
---

function VersionMapTests.map_returnsTrue_againstValidAlias()
	test.isEqual('Value2', Version.new('14.1.1.9', VERSION_MAP):map({
		['2019'] = 'Value1',
		['2017'] = 'Value2'
	}))
end

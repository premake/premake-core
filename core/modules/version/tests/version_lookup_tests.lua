local Version = require('version')

local VersionLookupTests = test.declare('VersionLookupTests', 'version')


local SUPPORTED_VERSIONS = {
	['2019'] = '16.*.*.*',
	['2017'] = '14.*.*.*',
	'12.3.*.*'
}


---
-- Aliases should return the corresponding full version, or `nil` if no
-- match can be found.
---

function VersionLookupTests.lookup_returnsVersion_onMatchingAlias()
	local result = Version.lookup('2019', SUPPORTED_VERSIONS)
	test.isEqual('16.*.*.*', toString(result))
end

function VersionLookupTests.lookup_returnsNil_onNoMatchingAlias()
	local result = Version.lookup('2018', SUPPORTED_VERSIONS)
	test.isNil(result)
end


---
-- If the target is not an alias, but is supported, return a `Version` instance around
-- the original target version.
---

function VersionLookupTests.lookup_returnsVersion_onSupportedTarget()
	local result = Version.lookup('16.1', SUPPORTED_VERSIONS)
	test.isEqual('16.1', toString(result))
end


---
-- A target is considered unsupported if there is supported version with the same
-- major version and same or earlier minor, patch, and build.
---

function VersionLookupTests.lookup_returnsNil_onTooHighVersion()
	local result = Version.lookup('18.0', SUPPORTED_VERSIONS)
	test.isNil(result)
end

function VersionLookupTests.lookup_returnsNil_onTooLowVersion()
	local result = Version.lookup('12.2', SUPPORTED_VERSIONS)
	test.isNil(result)
end


---
-- An integer target version should be converted to a string before testing.
---

function VersionLookupTests.lookup_convertsIntegerTargetToString()
	local result = Version.lookup(2019, SUPPORTED_VERSIONS)
	test.isEqual('16.*.*.*', toString(result))
end

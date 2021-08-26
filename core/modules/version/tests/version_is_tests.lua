local Version = require('version')

local VersionIsTests = test.declare('VersionIsTests', 'version')


local VERSION_MAP = {
	['2019'] = '16.*.*.*',
	['2017'] = '14.*.*.*'
}


function VersionIsTests.is_returnsTrue_onExactMatch()
	test.isTrue(Version.new('1.2.3.4'):is('1.2.3.4'))
end


function VersionIsTests.is_returnsTrue_onMatchWithWildcards()
	test.isTrue(Version.new('1.2.3.4'):is('1.*.*.*'))
end


function VersionIsTests.is_returnsFalse_onMajorMismatch()
	test.isFalse(Version.new('1.2.3.4'):is('2.2.3.4'))
end


function VersionIsTests.is_returnsFalse_onMinorMismatch()
	test.isFalse(Version.new('1.2.3.4'):is('1.1.3.4'))
end


function VersionIsTests.is_returnsFalse_onPatchMismatch()
	test.isFalse(Version.new('1.2.3.4'):is('1.2.1.4'))
end


function VersionIsTests.is_returnsFalse_onBuildMismatch()
	test.isFalse(Version.new('1.2.3.4'):is('1.2.3.1'))
end


---
-- Is the version was created with a version map it should be valid to
-- test against the aliases contained by that map.
---

function VersionIsTests.is_returnsTrue_againstValidAlias()
	test.isTrue(Version.new('14.1.1.9', VERSION_MAP):is('2017'))
end

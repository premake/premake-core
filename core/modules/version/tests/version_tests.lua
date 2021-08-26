local Version = require('version')

local VersionTests = test.declare('VersionTests', 'version')


---
-- The components of the version should be parsed out
---

function VersionTests.canIdentifyMajorVersion()
	test.isEqual('12', Version.new('12.3.4.3847').major)
end

function VersionTests.canIdentifyMinorVersion()
	test.isEqual('3', Version.new('12.3.4.3847').minor)
end

function VersionTests.canIdentifyPatchVersion()
	test.isEqual('4', Version.new('12.3.4.3847').patch)
end

function VersionTests.canIdentifyBuildVersion()
	test.isEqual('3847', Version.new('12.3.4.3847').build)
end


---
-- Any missing components should be filled in with a wildcard
---

function VersionTests.replacesMissingMinorVersionWithWildcard()
	test.isEqual('*', Version.new('12').minor)
end


---
-- For convenience, should be able to use versions like strings
---

function VersionTests.canConcatToString()
	local str = 'Version is ' .. Version.new('1.2.8')
	test.isEqual('Version is 1.2.8', str)
end


function VersionTests.canConvertToString()
	local str = 'Version is ' .. toString(Version.new('1.2.8'))
	test.isEqual('Version is 1.2.8', str)
end

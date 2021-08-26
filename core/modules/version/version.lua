---
-- Work with semantic version numbers.
---

local Type = require('type')

local Version = Type.declare('Version')


---
-- Create a new version instance.
--
-- @param value
--    The version string, ex. '12.1.4' or '15.0.7.44985'.
-- @param versionMap
--    An optional table mapping aliases such as "2017" to specific versions. Used
--    by methods like `is()` to enable testing against these aliased versions.
-- @returns
--    A new version instance.
---

function Version.new(value, versionMap)
	local parts = string.split(value, '.', true)
	return Type.assign(Version, {
		value = value,
		major = parts[1] or '*',
		minor = parts[2] or '*',
		patch = parts[3] or '*',
		build = parts[4] or '*',
		versionMap = versionMap or _EMPTY
	})
end


---
-- Allow versions to be exposed as strings as much as possible
---

function Version.__concat(previous, self)
	return previous .. self.value
end


function Version.__tostring(self)
	return self.value
end


---
-- Test if this version matches another.
--
-- @param version
--    The version to test against; may include the `*` wildcard.
-- @returns
--    True if the versions match, false otherwise.
---

function Version.is(self, version)
	-- if a version map is available, lookup aliased versions
	local testVersion = Version.new(self.versionMap[version] or version)
	return (testVersion.major == '*' or self.major == testVersion.major)
		and (testVersion.minor == '*' or self.minor == testVersion.minor)
		and (testVersion.patch == '*' or self.patch == testVersion.patch)
		and (testVersion.build == '*' or self.build == testVersion.build)
end


---
-- Class method. Checks a requested target version against a table of supported versions.
--
-- In order to be considered supported, there must be a supported version with same major
-- version, and whose remaining components are either the `*` wildcard, or a value which
-- is lower or equal to the target.
--
-- @param target
--    The target version to be tested.
-- @param supportedVersions
--    A key-value table of supported version numbers. The keys of this table are aliases
--    or "short names" for specific versions, ex. "2019" for Visual Studio 2019. The values
--    are the full version numbers associated with that short name, which may include the
--    `*` wildcard. Versions which do not have an alias can omit the key (array indexing).
-- @returns
--    If the target version is determined to be supported, returns a corresponding `Version`
--    instance. If the target version is not supported, returns `nil`.
---

function Version.lookup(target, supportedVersions)
	target = toString(target)

	-- If target matches a version alias, replace it with the corresponding full version
	target = supportedVersions[target] or target

	-- Compare target to all entries in the list. If any are compatible, the test passes
	local targetVersion = Version.new(target, supportedVersions)
	for _, version in pairs(supportedVersions) do
		local testVersion = Version.new(version)
		if testVersion.major == targetVersion.major
			and (testVersion.minor == '*' or testVersion.minor <= targetVersion.minor)
			and (testVersion.patch == '*' or testVersion.patch <= targetVersion.patch)
			and (testVersion.build == '*' or testVersion.build <= targetVersion.build)
		then
			return targetVersion
		end
	end
end


---
-- Use this version as a lookup key in a version-value map.
--
-- @params valueMap
--    A table of version-value pairs. The keys of the table are version
--    patterns to be matched against, which can use wildcards. If a version
--    map was supplied when the version was created (i.e. `Version.lookup()`)
--    then aliases from that version map may also be used as keys.
-- @returns
--    The corresponding value from the map, or `nil` if no match is found.
---

function Version.map(self, valueMap)
	for version, value in pairs(valueMap) do
		version = self.versionMap[version] or version
		if Version.is(self, version) then
			return value
		end
	end
end


return Version

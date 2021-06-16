local array = require('array')
local path = require('path')
local set = require('set')
local tree = require('tree')

local vstudio = select(1, ...)
local vcxproj = vstudio.vcxproj

local utils = {}


---
-- Builds a source tree hierarchy applying any virtual paths.
--
-- @param prj
--    The project being exported.
-- @param files
--    An array containing the project's source file list.
-- @returns
--    A `Tree` object containing the processed source file hierarchy.
---

function utils.buildVirtualSourceTree(prj, files)
	local sourceTree = tree.new()

	for i = 1, #files do
		local filePath = path.getRelative(prj.baseDirectory, files[i])
		-- TODO: virtual paths, generated files...
		tree.add(sourceTree, filePath)
	end

	tree.sort(sourceTree)
	return sourceTree
end


---
-- VS expects all source files to be specified at the project level, even those which
-- are specific to only a subset of the configurations. Collect all files across all
-- configurations associated with the project.
--
-- @returns
--    An array of absolute source file paths.
---

function utils.collectAllSourceFiles(prj)
	local files = {}

	local prjFiles = prj.files
	for fi = 1, #prjFiles do
		set.append(files, prjFiles[fi])
	end

	for ci = 1, #prj.configs do
		local cfgFiles = prj.configs[ci].files
		for fi = 1, #cfgFiles do
			set.append(files, cfgFiles[fi])
		end
	end

	return files
end


---
-- Sort project source files into target tool categories, e.g. `ClCompile`, `ClInclude`. See
-- `vcxproj.categories` table in `vcxproj.lua`.
--
-- @param prj
--    The project being exported.
-- @param files
--    An array containing the project's source file list.
-- @returns
--    A table keyed by `vcxproj.categories` items, with each key pointing to an array of
--    absolute source file paths relevant to that category.
---

function utils.categorizeSourceFiles(prj, files)
	local categorizedFiles = {}

	-- create empty lists for each category
	local categories = vcxproj.categories
	for ci = 1, #categories do
		categorizedFiles[ci] = {}
	end

	for fi = 1, #files do
		local file = files[fi]
		for ci = 1, #categories do
			local category = categories[ci]
			if category.match(file) then
				table.insert(categorizedFiles[ci], file)
				break
			end
		end
	end

	return categorizedFiles
end


return utils

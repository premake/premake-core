local path = require('path')
local set = require('set')
local State = require('state')
local tree = require('tree')
local Type = require('type')

local dom = select(1, ...)

local Project = Type.declare('Project', State)


---
-- Instantiate a new project configuration helper.
--
-- @param state
--    The project configuration state.
-- @returns
--    A new project helper instance.
---

function Project.new(state)
	local prj = Type.assign(Project, state)

	local name = state.projects[1]
	prj.name = name
	prj.filename = prj.filename or name
	prj.location = prj.location or prj.baseDir or os.getCwd()

	return prj
end


---
-- Builds a tree from a project's list of files. Branch nodes are created for each
-- subdirectory or virtual path, with source files at the leaves.
--
-- @param files
--    An array containing the project's source file list. If not provided, will be
--    retrieved via `Project.collectAllSourceFiles()`.
-- @returns
--    A `Tree` object containing the source file hierarchy.
---

function Project.buildSourceTree(self, files)
	files = files or Project.collectAllSourceFiles(self)

	local sourceTree = tree.new()

	for i = 1, #files do
		local filePath = path.getRelative(self.baseDirectory, files[i])
		-- TODO: virtual paths, generated files...
		tree.add(sourceTree, filePath)
	end

	tree.sort(sourceTree)
	return sourceTree
end


---
-- Some exporters (Visual Studio, Xcode) expect all source files to be listed at the project
-- level, even those which are specific to only a subset of the configurations. Collect all
-- files across all configurations associated with the project.
--
-- @returns
--    An array of absolute source file paths.
---

function Project.collectAllSourceFiles(self)
	local files = {}

	local prjFiles = self.files
	for fi = 1, #prjFiles do
		set.append(files, prjFiles[fi])
	end

	for ci = 1, #self.configs do
		local cfgFiles = self.configs[ci]:withoutInheritance().files
		for fi = 1, #cfgFiles do
			set.append(files, cfgFiles[fi])
		end
	end

	return files
end


---
-- Retrieve the configurations contained by this project.
--
-- @param createCallback
--    A function with signature `(project, build, platform)` which will be called for
--    each build/platform pair found in the project. Return a new `dom.Config` to represent
--    the configuration, or `nil` to ignore it.
-- @returns
--    An array of `dom.Config`.
---

function Project.fetchConfigs(self, createCallback)
	local configs = {}

	local selectors = dom.Config.fetchConfigPlatformPairs(self)
	for i = 1, #selectors do
		local selector = selectors[i]
		local cfg = createCallback(self, selector.configurations, selector.platforms)
		configs[i] = cfg
		configs[cfg.name] = cfg
	end

	return configs
end


---
-- Retrieve the blocks contained by this project.
--
-- @param createCallback
--    A function with the signature `(project, blockName)` which will be called for
--    each block name found in the workspace. Return a new `dom.Block` to represent
--    the project, or `nil` to ignore it.
-- @returns
--    A table of projects, keyed by integer index and block name.
---

function Project.fetchBlocks(self, createCallback)
	local blocks = {}

	local names = self.blocks
	for i = 1, #names do
		local name = names[i]
		local block = createCallback(self, name)
		blocks[i] = block
		blocks[name] = block
	end

	return blocks
end


---
-- Convert absolute paths to project relative.
---

function Project.makeRelative(self, paths)
	return path.getRelative(self.baseDirectory, paths)
end


return Project

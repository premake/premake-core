---
-- usage.lua
-- Premake usage object API
-- Author Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
---

	local p = premake
	p.usage = p.api.container("usage", p.project, { "config" })

	local usage = p.usage

	p.usage.PUBLIC = "PUBLIC"
	p.usage.PRIVATE = "PRIVATE"
	p.usage.INTERFACE = "INTERFACE"

---
-- Create a new usage container instance.
--
-- @param name
--    The name of the usage container.
-- @return
--	  The new usage container.
---

	function usage.new(name)
		local use = p.container.new(usage, name)
		use.filename = nil
		use.basedir = nil
		use.project = p.api.scope.project
		use.noinherit = true
		return use
	end


---
-- Checks if a usage name is a magic name (PUBLIC, PRIVATE, INTERFACE)
--
-- @param name
--   The name of the usage.
-- @return
--   True if the usage is a special usage.
---

	function usage.isSpecialName(name)
		return name == usage.PUBLIC or name == usage.PRIVATE or name == usage.INTERFACE
	end


---
-- Check if the usage has a magic name (PUBLIC, PRIVATE, INTERFACE)
--
-- @param self
--	  The usage object.
-- @return
--	  True if the usage is a special usage.
---

	function usage.isSpecial(self)
		return usage.isSpecialName(self.name)
	end


---
-- Find a usage with the provided name in the global scope.
--
-- @param name
--    The name of the usage to find.
-- @return
--    A list of usages with the provided name.
---
	function usage.findglobal(name)
		-- First, try to find a project with the provided name in the global scope
		for wks in p.global.eachWorkspace() do
			-- For each workspace, check if a project with the provided name exists
			local prj = p.workspace.findproject(wks, name)
			if prj then
				-- Check if the project has a public or interface usage
				local publicUsage = p.project.findusage(prj, usage.PUBLIC)
				local interfaceUsage = p.project.findusage(prj, usage.INTERFACE)

				local result = {}
				if publicUsage then
					table.insert(result, publicUsage)
				end

				if interfaceUsage then
					table.insert(result, interfaceUsage)
				end

				return result
			end

			-- If no project with a matching name was found, check each project to see if it has a usage
			-- with the provided name
			for prj in p.workspace.eachproject(wks) do
				local usage = p.project.findusage(prj, name)
				if usage then
					return { usage }
				end
			end
		end

		return {}
	end

--
-- vslatest.lua
-- Extend the existing exporters with support for Visual Studio 2019.
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	local vstudio = p.vstudio
	local latest = nil

	function getLatestVisualStudioVersion()
		-- Get the most recent version installed
		if latest == nil then
			local version = nil
			if os.host() == 'windows' then
				local ver, err = os.outputof('"C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe" -latest -property catalog_productLineVersion')
				if err ~= nil and err == 0 then
					version = 'vs' .. ver
				end
			end

			if version == nil then
				version = "vs2019"
				print("No Visual Studio installation found using vswhere.exe. Defaulting to " .. _ACTION .. ".")
			end

			latest = p.action.get(version)
		end
	
		return latest
	end

---
-- Define the Visual Studio Latest export action.
---

	newaction {
		-- Metadata for the command line and help system
		
		trigger	    = "vs-latest",
		shortname   = "Visual Studio - Latest",
		description = "Generate Visual Studio project files for latest installation",

		-- Copy data from the latest vs action
		
		targetos         = getLatestVisualStudioVersion().targetos,
		toolset          = getLatestVisualStudioVersion().toolset,
		valid_kinds      = getLatestVisualStudioVersion().valid_kinds,
		valid_tools      = getLatestVisualStudioVersion().valid_tools,
		onWorkspace      = getLatestVisualStudioVersion().onWorkspace,
		onProject        = getLatestVisualStudioVersion().onProject,
		onRule           = getLatestVisualStudioVersion().onRule,
		onCleanWorkspace = getLatestVisualStudioVersion().onCleanWorkspace,
		onCleanProject   = getLatestVisualStudioVersion().onCleanProject,
		onCleanTarget    = getLatestVisualStudioVersion().onCleanTarget,
		pathVars         = getLatestVisualStudioVersion().pathVars,
		vstudio          = getLatestVisualStudioVersion().vstudio,
	}
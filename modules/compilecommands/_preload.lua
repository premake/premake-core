--
-- _preload.lua
-- Define the compilecommands actions
-- Author: Nick Clark
-- Copyright (c) 2026 Jess Perkins and the Premake project
--

local p = premake

newoption {
	category = "Compilation Database",

	trigger = "cc-config",
	description = "Specify the configuration to generate compile_commands.json for",
}

newoption {
	category = "Compilation Database",

	trigger = "cc-platform",
	description = "Specify the platform to generate compile_commands.json for",
}

newoption {
	category = "Compilation Database",

	trigger = "cc-output",
	description = "Specify the output file path for compile_commands.json",
}

newaction {
	trigger = "compilecommands",
	shortname = "compilecommands",
	description = "Generate compile_commands.json files",

	-- Action Capabilities
	valid_kinds = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
	valid_languages = { "C", "C++" },
	valid_tools = {
		cc = { "clang", "cosmocc", "emcc", "gcc" },
	},

	toolset = "clang",

	onInitialize = function()
		require("compilecommands")
	end,

	configurable = true,

	execute = function()
		local all_commands = {}

		for wks in p.global.eachWorkspace() do
			-- Platform is set in the following order of precedence
			-- 1. Command line option
			-- 2. Workspace default platform
			-- 3. Empty string
			local platform = _OPTIONS["cc-platform"] or wks.defaultplatform or ""

			-- Configuration is set in the following order of precedence
			-- 1. Command line option
			-- 2. First build configuration of the workspace
			-- 3. Empty string
			local buildcfg = _OPTIONS["cc-config"] or wks.configurations[1] or ""

			local compile_commands = p.modules.compilecommands.generate(wks, platform, buildcfg)
			all_commands = table.join(all_commands, compile_commands)
		end

		local results, err = json.encode(all_commands)
		if not results then
			p.error("Failed to encode compile commands to JSON: %s", err)
			return
		end

		local output_path = _OPTIONS["cc-output"] or "compile_commands.json"

		local dir = path.getdirectory(output_path)
		local ok, err = os.mkdir(dir)
		if not ok then
			error(err, 0)
		end

		local f, err = os.writefile_ifnotequal(results, output_path)
		if err then
			p.error("Failed to write compile_commands.json: %s", err)
		elseif f ~= 0 then
			printf("Generated %s...", path.getrelative(os.getcwd(), output_path))
		end
	end
}

return function(cfg)
	return (_ACTION == "compilecommands")
end

--
-- _manifest.lua
-- Manage the list of built-in Premake scripts.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
--

-- The master list of built-in scripts. Order is important! If you want to
-- build a new script into Premake, add it to this list.

	return
	{
		-- core files
		"base/_foundation.lua",
		"base/string.lua",
		"base/table.lua",
		"base/path.lua",
		"base/os.lua",
		"base/io.lua",
		"base/tools.lua",
		"base/tree.lua",
		"base/globals.lua",
		"base/moduledownloader.lua",
		"base/semver.lua",
		"base/http.lua",
		"base/json.lua",
		"base/jsonwrapper.lua",
		"base/languages.lua",
		"base/term.lua",

		-- configuration data
		"base/field.lua",
		"base/criteria.lua",
		"base/detoken.lua",
		"base/configset.lua",
		"base/context.lua",
		"base/container.lua",

		-- runtime switches
		"base/option.lua",
		"base/action.lua",

		-- project script setup
		"base/api.lua",

		-- project objects
		"base/global.lua",
		"base/workspace.lua",
		"base/group.lua",
		"base/project.lua",
		"base/config.lua",
		"base/fileconfig.lua",
		"base/rule.lua",

		-- project script processing
		"base/oven.lua",
		"base/validation.lua",
		"base/premake.lua",
		"base/help.lua",

		-- tool APIs
		"tools/dotnet.lua",
		"tools/gcc.lua",
		"tools/msc.lua",
		"tools/snc.lua",
		"tools/clang.lua",

		-- GNU make action
		"actions/make/_make.lua",
		"actions/make/make_workspace.lua",
		"actions/make/make_cpp.lua",
		"actions/make/make_csharp.lua",
		"actions/make/make_utility.lua",
		"actions/make/make_makefile.lua",

		-- Visual Studio actions
		"actions/vstudio/_vstudio.lua",
		"actions/vstudio/vs2005.lua",
		"actions/vstudio/vs2008.lua",
		"actions/vstudio/vs200x_vcproj.lua",
		"actions/vstudio/vs200x_vcproj_user.lua",
		"actions/vstudio/vs2005_solution.lua",
		"actions/vstudio/vs2005_csproj.lua",
		"actions/vstudio/vs2005_csproj_user.lua",
		"actions/vstudio/vs2010.lua",
		"actions/vstudio/vs2010_nuget.lua",
		"actions/vstudio/vs2010_vcxproj.lua",
		"actions/vstudio/vs2010_vcxproj_user.lua",
		"actions/vstudio/vs2010_vcxproj_filters.lua",
		"actions/vstudio/vs2010_rules_props.lua",
		"actions/vstudio/vs2010_rules_targets.lua",
		"actions/vstudio/vs2010_rules_xml.lua",
		"actions/vstudio/vs2012.lua",
		"actions/vstudio/vs2013.lua",
		"actions/vstudio/vs2015.lua",
		"actions/vstudio/vs2017.lua",

		-- Clean action
		"actions/clean/_clean.lua",

		"_premake_init.lua",
	}

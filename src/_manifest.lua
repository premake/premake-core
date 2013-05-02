--
-- _manifest.lua
-- Manage the list of built-in Premake scripts.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--

-- The master list of built-in scripts. Order is important! If you want to
-- build a new script into Premake, add it to this list.

	return
	{
		-- Lua extensions
		"base/os.lua",
		"base/path.lua",
		"base/string.lua",
		"base/table.lua",

		-- core files
		"base/io.lua",
		"base/globals.lua",
		"base/action.lua",
		"base/criteria.lua",
		"base/option.lua",
		"base/tree.lua",
		"base/project.lua",
		"base/config.lua",
		"base/help.lua",

		-- configuration APIs
		"base/configset.lua",
		"base/context.lua",
		"base/api.lua",
		"base/detoken.lua",

		-- runtime environment setup
		"_premake_init.lua",
		"base/cmdline.lua",

		-- project APIs
		"project/project.lua",
		"project/config.lua",
		"base/solution.lua",
		"base/premake.lua",

		-- tool APIs
		"tools/dotnet.lua",
		"tools/gcc.lua",
		"tools/msc.lua",
		"tools/snc.lua",
		"tools/clang.lua",

		-- GNU make action
		"actions/make/_make.lua",
		"actions/make/make_solution.lua",
		"actions/make/make_cpp.lua",
		"actions/make/make_csharp.lua",

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
		"actions/vstudio/vs2010_vcxproj.lua",
		"actions/vstudio/vs2010_vcxproj_user.lua",
		"actions/vstudio/vs2010_vcxproj_filters.lua",
		"actions/vstudio/vs2012.lua",

		-- Clean action
		"actions/clean/_clean.lua",
	}

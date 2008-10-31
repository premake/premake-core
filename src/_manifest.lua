--
-- _manifest.lua
-- Manage the list of built-in Premake scripts.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


-- The master list of built-in scripts. Order is important! If you want to
-- build a new script into Premake, add it to this list.

	local scripts =
	{
		"base/path.lua",
		"base/string.lua",
		"base/table.lua",
		"base/os.lua",
		"base/globals.lua",
		"base/premake.lua",
		"base/template.lua",
		"base/project.lua",
		"base/functions.lua",
		"base/gcc.lua",
		
		-- this one must be last
		"_premake_main.lua"
	}


-- The list of templates

	local templates = 
	{
		"actions/make/make_solution.tmpl",
		"actions/make/make_cpp_project.tmpl",
		"actions/vstudio/vs2002_solution.tmpl",
	}
	
	
-- The list of built in actions

	local actions = 
	{
		"actions/clean/_clean.lua",
		"actions/make/_make.lua",
		"actions/vstudio/_vstudio.lua",
	}
	
	
	
	return scripts, templates, actions
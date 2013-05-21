--
-- tests/premake4.lua
-- Automated test suite for Premake 4.x
-- Copyright (c) 2008-2013 Jason Perkins and the Premake project
--

	dofile("testfx.lua")

--
-- Some helper functions
--

	test.createsolution = function()
		local sln = solution "MySolution"
		configurations { "Debug", "Release" }

		local prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"

		return sln, prj
	end


	test.createproject = function(sln)
		local n = #sln.projects + 1
		if n == 1 then n = "" end

		local prj = project ("MyProject" .. n)
		language "C++"
		kind "ConsoleApp"
		return prj
	end


--
-- The test suites
--

	-- Base API tests
	dofile("test_dofile.lua")
	dofile("test_string.lua")

	dofile("base/test_configset.lua")
	dofile("base/test_context.lua")
	dofile("base/test_criteria.lua")
	dofile("base/test_detoken.lua")
	dofile("base/test_include.lua")
	dofile("base/test_os.lua")
	dofile("base/test_override.lua")
	dofile("base/test_path.lua")
	dofile("base/test_premake_command.lua")
	dofile("base/test_table.lua")
	dofile("base/test_tree.lua")
	dofile("base/test_uuid.lua")

	-- Solution object tests
	dofile("solution/test_eachconfig.lua")
	dofile("solution/test_objdirs.lua")

	-- Project object tests
	dofile("project/test_config_maps.lua")
	dofile("project/test_eachconfig.lua")
	dofile("project/test_filename.lua")
	dofile("project/test_getconfig.lua")
	dofile("project/test_hasconfig.lua")
	dofile("project/test_vpaths.lua")

	-- Configuration object tests
	dofile("config/test_fileconfig.lua")
	dofile("config/test_linkinfo.lua")
	dofile("config/test_links.lua")
	dofile("config/test_targetinfo.lua")

	-- API tests
	dofile("api/test_array_kind.lua")
	dofile("api/test_callback.lua")
	dofile("api/test_containers.lua")
	dofile("api/test_list_kind.lua")
	dofile("api/test_path_kind.lua")
	dofile("api/test_register.lua")
	dofile("api/test_string_kind.lua")

	-- Control system tests
	dofile("test_premake.lua")
	dofile("base/test_validation.lua")

	-- Toolset tests
	dofile("tools/test_dotnet.lua")
	dofile("tools/test_gcc.lua")
	dofile("tools/test_msc.lua")
	dofile("tools/test_snc.lua")

	-- Visual Studio 2005-2010 C# projects
	dofile("actions/vstudio/cs2005/test_assembly_refs.lua")
	dofile("actions/vstudio/cs2005/test_build_events.lua")
	dofile("actions/vstudio/cs2005/test_compiler_props.lua")
	dofile("actions/vstudio/cs2005/test_debug_props.lua")
	dofile("actions/vstudio/cs2005/test_files.lua")
	dofile("actions/vstudio/cs2005/test_icon.lua")
	dofile("actions/vstudio/cs2005/test_output_props.lua")
	dofile("actions/vstudio/cs2005/projectelement.lua")
	dofile("actions/vstudio/cs2005/test_platform_groups.lua")
	dofile("actions/vstudio/cs2005/test_project_refs.lua")
	dofile("actions/vstudio/cs2005/projectsettings.lua")

	-- Visual Studio 2005-2010 solutions
	dofile("actions/vstudio/sln2005/test_dependencies.lua")
	dofile("actions/vstudio/sln2005/test_header.lua")
	dofile("actions/vstudio/sln2005/test_nested_projects.lua")
	dofile("actions/vstudio/sln2005/test_projects.lua")
	dofile("actions/vstudio/sln2005/test_platforms.lua")

	-- Visual Studio 2002-2008 C/C++ projects
	dofile("actions/vstudio/vc200x/test_assembly_refs.lua")
	dofile("actions/vstudio/vc200x/test_build_steps.lua")
	dofile("actions/vstudio/vc200x/test_configuration.lua")
	dofile("actions/vstudio/vc200x/test_compiler_block.lua")
	dofile("actions/vstudio/vc200x/test_debug_settings.lua")
	dofile("actions/vstudio/vc200x/test_excluded_configs.lua")
	dofile("actions/vstudio/vc200x/test_external_compiler.lua")
	dofile("actions/vstudio/vc200x/test_external_linker.lua")
	dofile("actions/vstudio/vc200x/test_files.lua")
	dofile("actions/vstudio/vc200x/test_linker_block.lua")
	dofile("actions/vstudio/vc200x/test_manifest_block.lua")
	dofile("actions/vstudio/vc200x/test_nmake_settings.lua")
	dofile("actions/vstudio/vc200x/test_platforms.lua")
	dofile("actions/vstudio/vc200x/test_project.lua")
	dofile("actions/vstudio/vc200x/test_project_refs.lua")
	dofile("actions/vstudio/vc200x/test_resource_compiler.lua")

	-- Visual Studio 2010 C/C++ projects
	dofile("actions/vstudio/vc2010/test_assembly_refs.lua")
	dofile("actions/vstudio/vc2010/test_compile_settings.lua")
	dofile("actions/vstudio/vc2010/test_config_props.lua")
	dofile("actions/vstudio/vc2010/test_debug_settings.lua")
	dofile("actions/vstudio/vc2010/test_excluded_configs.lua")
	dofile("actions/vstudio/vc2010/test_globals.lua")
	dofile("actions/vstudio/vc2010/test_header.lua")
	dofile("actions/vstudio/vc2010/test_files.lua")
	dofile("actions/vstudio/vc2010/test_filter_ids.lua")
	dofile("actions/vstudio/vc2010/test_filters.lua")
	dofile("actions/vstudio/vc2010/test_item_def_group.lua")
	dofile("actions/vstudio/vc2010/test_link.lua")
	dofile("actions/vstudio/vc2010/test_nmake_props.lua")
	dofile("actions/vstudio/vc2010/test_output_props.lua")
	dofile("actions/vstudio/vc2010/test_project_configs.lua")
	dofile("actions/vstudio/vc2010/test_project_refs.lua")
	dofile("actions/vstudio/vc2010/test_prop_sheet.lua")
	dofile("actions/vstudio/vc2010/test_resource_compile.lua")

	-- Visual Studio 2012
	dofile("actions/vs2012/test_csproj_common_props.lua")
	dofile("actions/vs2012/test_csproj_project_element.lua")
	dofile("actions/vs2012/test_csproj_project_props.lua")
	dofile("actions/vs2012/test_csproj_targets.lua")
	dofile("actions/vs2012/test_sln_header.lua")
	dofile("actions/vs2012/test_vcxproj_config_props.lua")

	-- Makefile tests
	dofile("actions/make/test_make_escaping.lua")
	dofile("actions/make/test_make_tovar.lua")

	-- Makefile solutions
	dofile("actions/make/solution/test_config_maps.lua")
	dofile("actions/make/solution/test_default_config.lua")
	dofile("actions/make/solution/test_help_rule.lua")
	dofile("actions/make/solution/test_project_rule.lua")

	-- Makefile C/C++ projects
	dofile("actions/make/cpp/test_clang.lua")
	dofile("actions/make/cpp/test_file_rules.lua")
	dofile("actions/make/cpp/test_flags.lua")
	dofile("actions/make/cpp/test_make_pch.lua")
	dofile("actions/make/cpp/test_make_linking.lua")
	dofile("actions/make/cpp/test_objects.lua")
	dofile("actions/make/cpp/test_ps3.lua")
	dofile("actions/make/cpp/test_target_rules.lua")
	dofile("actions/make/cpp/test_wiidev.lua")

	-- Makefile C# projects
	dofile("actions/make/cs/test_flags.lua")


--
-- Register a test action
--

	newoption {
		trigger     = "test",
		description = "A suite or test to run"
	}

	newaction {
		trigger     = "test",
		description = "Run the automated test suite",

		execute = function ()
			if _OPTIONS["test"] then
				local t = string.explode(_OPTIONS["test"] or "", ".", true)
				passed, failed = test.runall(t[1], t[2])
			else
				passed, failed = test.runall()
			end

			msg = string.format("%d tests passed, %d failed", passed, failed)
			if (failed > 0) then
				-- should probably return an error code here somehow
				print(msg)
			else
				print(msg)
			end
		end
	}

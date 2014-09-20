return {
	-- Base API tests
	"test_dofile.lua",
	"test_string.lua",
	"base/test_configset.lua",
	"base/test_context.lua",
	"base/test_criteria.lua",
	"base/test_detoken.lua",
	"base/test_include.lua",
	"base/test_option.lua",
	"base/test_os.lua",
	"base/test_override.lua",
	"base/test_path.lua",
	"base/test_premake_command.lua",
	"base/test_table.lua",
	"base/test_tree.lua",
	"base/test_uuid.lua",

	-- Solution object tests
	"solution/test_eachconfig.lua",
	"solution/test_location.lua",
	"solution/test_objdirs.lua",

	-- Project object tests
	"project/test_config_maps.lua",
	"project/test_eachconfig.lua",
	"project/test_getconfig.lua",
	"project/test_location.lua",
	"project/test_vpaths.lua",

	-- Configuration object tests
	"config/test_linkinfo.lua",
	"config/test_links.lua",
	"config/test_targetinfo.lua",

	-- Baking tests
	"oven/test_filtering.lua",
	"oven/test_objdirs.lua",

	-- API tests
	"api/test_containers.lua",
	"api/test_directory_kind.lua",
	"api/test_list_kind.lua",
	"api/test_path_kind.lua",
	"api/test_register.lua",
	"api/test_string_kind.lua",
	"api/test_table_kind.lua",

	-- Control system tests
	"test_premake.lua",
	"base/test_validation.lua",

	-- -- Toolset tests
	"tools/test_dotnet.lua",
	"tools/test_gcc.lua",
	"tools/test_msc.lua",

	-- Visual Studio 2005-2010 C# projects
	"actions/vstudio/cs2005/test_assembly_refs.lua",
	"actions/vstudio/cs2005/test_build_events.lua",
	"actions/vstudio/cs2005/test_compiler_props.lua",
	"actions/vstudio/cs2005/test_debug_props.lua",
	"actions/vstudio/cs2005/test_files.lua",
	"actions/vstudio/cs2005/test_icon.lua",
	"actions/vstudio/cs2005/test_output_props.lua",
	"actions/vstudio/cs2005/projectelement.lua",
	"actions/vstudio/cs2005/test_platform_groups.lua",
	"actions/vstudio/cs2005/test_project_refs.lua",
	"actions/vstudio/cs2005/projectsettings.lua",

	-- Visual Studio 2005-2010 solutions
	"actions/vstudio/sln2005/test_dependencies.lua",
	"actions/vstudio/sln2005/test_header.lua",
	"actions/vstudio/sln2005/test_nested_projects.lua",
	"actions/vstudio/sln2005/test_projects.lua",
	"actions/vstudio/sln2005/test_platforms.lua",

	-- Visual Studio 2002-2008 C/C++ projects
	"actions/vstudio/vc200x/test_assembly_refs.lua",
	"actions/vstudio/vc200x/test_build_steps.lua",
	"actions/vstudio/vc200x/test_configuration.lua",
	"actions/vstudio/vc200x/test_compiler_block.lua",
	"actions/vstudio/vc200x/test_debug_settings.lua",
	"actions/vstudio/vc200x/test_excluded_configs.lua",
	"actions/vstudio/vc200x/test_files.lua",
	"actions/vstudio/vc200x/test_linker_block.lua",
	"actions/vstudio/vc200x/test_manifest_block.lua",
	"actions/vstudio/vc200x/test_nmake_settings.lua",
	"actions/vstudio/vc200x/test_platforms.lua",
	"actions/vstudio/vc200x/test_project.lua",
	"actions/vstudio/vc200x/test_project_refs.lua",
	"actions/vstudio/vc200x/test_resource_compiler.lua",

	-- Visual Studio 2010 C/C++ projects
	"actions/vstudio/vc2010/test_assembly_refs.lua",
	"actions/vstudio/vc2010/test_build_events.lua",
	"actions/vstudio/vc2010/test_compile_settings.lua",
	"actions/vstudio/vc2010/test_config_props.lua",
	"actions/vstudio/vc2010/test_debug_settings.lua",
	"actions/vstudio/vc2010/test_excluded_configs.lua",
	"actions/vstudio/vc2010/test_extension_settings.lua",
	"actions/vstudio/vc2010/test_extension_targets.lua",
	"actions/vstudio/vc2010/test_globals.lua",
	"actions/vstudio/vc2010/test_header.lua",
	"actions/vstudio/vc2010/test_files.lua",
	"actions/vstudio/vc2010/test_filter_ids.lua",
	"actions/vstudio/vc2010/test_filters.lua",
	"actions/vstudio/vc2010/test_imagexex_settings.lua",
	"actions/vstudio/vc2010/test_item_def_group.lua",
	"actions/vstudio/vc2010/test_link.lua",
	"actions/vstudio/vc2010/test_manifest.lua",
	"actions/vstudio/vc2010/test_nmake_props.lua",
	"actions/vstudio/vc2010/test_output_props.lua",
	"actions/vstudio/vc2010/test_project_configs.lua",
	"actions/vstudio/vc2010/test_project_refs.lua",
	"actions/vstudio/vc2010/test_prop_sheet.lua",
	"actions/vstudio/vc2010/test_resource_compile.lua",

	-- Visual Studio 2012
	"actions/vs2012/test_csproj_common_props.lua",
	"actions/vs2012/test_csproj_project_element.lua",
	"actions/vs2012/test_csproj_project_props.lua",
	"actions/vs2012/test_csproj_targets.lua",
	"actions/vs2012/test_sln_header.lua",
	"actions/vs2012/test_vcxproj_clcompile.lua",
	"actions/vs2012/test_vcxproj_config_props.lua",

	-- Visual Studio 2013
	"actions/vs2013/test_csproj_project_element.lua",
	"actions/vs2013/test_globals.lua",
	"actions/vs2013/test_sln_header.lua",
	"actions/vs2013/test_vcxproj_config_props.lua",

	-- Makefile tests
	"actions/make/test_make_escaping.lua",
	"actions/make/test_make_tovar.lua",

	-- Makefile solutions
	"actions/make/solution/test_config_maps.lua",
	"actions/make/solution/test_default_config.lua",
	"actions/make/solution/test_help_rule.lua",
	"actions/make/solution/test_project_rule.lua",

	-- Makefile C/C++ projects
	"actions/make/cpp/test_clang.lua",
	"actions/make/cpp/test_file_rules.lua",
	"actions/make/cpp/test_flags.lua",
	"actions/make/cpp/test_make_pch.lua",
	"actions/make/cpp/test_make_linking.lua",
	"actions/make/cpp/test_objects.lua",
	"actions/make/cpp/test_target_rules.lua",
	"actions/make/cpp/test_tools.lua",
	"actions/make/cpp/test_wiidev.lua",

	-- Makefile C# projects
	"actions/make/cs/test_embed_files.lua",
	"actions/make/cs/test_flags.lua",
	"actions/make/cs/test_links.lua",
	"actions/make/cs/test_response.lua",
	"actions/make/cs/test_sources.lua",

}

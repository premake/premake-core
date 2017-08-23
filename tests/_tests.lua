return {
	-- Base API tests
	"test_string.lua",
	"base/test_aliasing.lua",
	"base/test_binmodules.lua",
	"base/test_configset.lua",
	"base/test_context.lua",
	"base/test_criteria.lua",
	"base/test_detoken.lua",
	"base/test_include.lua",
	"base/test_module_loader.lua",
	"base/test_option.lua",
	"base/test_os.lua",
	"base/test_override.lua",
	"base/test_path.lua",
	"base/test_premake_command.lua",
	"base/test_table.lua",
	"base/test_tree.lua",
	"base/test_uuid.lua",
	"base/test_versions.lua",
	"base/test_http.lua",
	"base/test_json.lua",

	-- Workspace object tests
	"workspace/test_eachconfig.lua",
	"workspace/test_location.lua",
	"workspace/test_objdirs.lua",

	-- Project object tests
	"project/test_config_maps.lua",
	"project/test_eachconfig.lua",
	"project/test_getconfig.lua",
	"project/test_location.lua",
	"project/test_sources.lua",
	"project/test_vpaths.lua",

	-- Configuration object tests
	"config/test_linkinfo.lua",
	"config/test_links.lua",
	"config/test_targetinfo.lua",

	-- Baking tests
	"oven/test_filtering.lua",
	"oven/test_objdirs.lua",

	-- API tests
	"api/test_boolean_kind.lua",
	"api/test_containers.lua",
	"api/test_directory_kind.lua",
	"api/test_list_kind.lua",
	"api/test_path_kind.lua",
	"api/test_register.lua",
	"api/test_string_kind.lua",
	"api/test_table_kind.lua",
	"api/test_deprecations.lua",

	-- Control system tests
	"test_premake.lua",
	"base/test_validation.lua",

	-- -- Toolset tests
	"tools/test_dotnet.lua",
	"tools/test_gcc.lua",
	"tools/test_msc.lua",
}

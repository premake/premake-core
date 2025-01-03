require ("gmakelegacy")

return {
	-- Makefile tests
	"test_make_escaping.lua",
	"test_make_tovar.lua",

	-- Makefile workspaces
	"workspace/test_config_maps.lua",
	"workspace/test_default_config.lua",
	"workspace/test_group_rule.lua",
	"workspace/test_help_rule.lua",
	"workspace/test_project_rule.lua",

	-- Makefile C/C++ projects
	"cpp/test_clang.lua",
	"cpp/test_file_rules.lua",
	"cpp/test_flags.lua",
	"cpp/test_ldflags.lua",
	"cpp/test_make_pch.lua",
	"cpp/test_make_linking.lua",
	"cpp/test_objects.lua",
	"cpp/test_target_rules.lua",
	"cpp/test_tools.lua",
	"cpp/test_wiidev.lua",

	-- Makefile C# projects
	"cs/test_embed_files.lua",
	"cs/test_flags.lua",
	"cs/test_links.lua",
	"cs/test_response.lua",
	"cs/test_sources.lua",
}

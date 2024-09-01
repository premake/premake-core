--
-- git_integration.lua
--
-- Code for git integration.
--
-- Copyright (c) 2024 Jason Perkins and the Premake project
--

local p = premake
local api = p.api
p.git_integration = {}
local m = p.git_integration

-----------------------------------------------------------------------------
--
-- Register gitintegration.
--
-----------------------------------------------------------------------------

api.register {
	name = "gitintegration",
	scope = "global",
	kind = "string",
	allowed = {
		"Off",
		"Always",
		"OnNewFiles"
	}
}

---
-- Find root directory (directory containing '.git' directory).
---
local function find_git_root(current_path)
	current_path = path.getabsolute(current_path or _MAIN_SCRIPT_DIR)

	while not os.isdir(path.join(current_path, ".git")) do
		current_path = path.getdirectory(current_path)
		if current_path == "" then
			error("No git root path")
		end
	end
	return current_path
end

---
-- Write git post-checkout content
---
local function print_git_post_checkout_hooks(root_path, mode)
	local args = {}
	for _, arg in ipairs(_ARGV) do
		if not (arg:startswith("--file") or arg:startswith("/file")) then
			table.insert(args, arg);
		end
	end

	local indent = ''
	p.outln('#!/bin/sh')
	if mode == 'OnNewFiles' then
		p.outln('count=`git diff --compact-summary $1 $2 | grep -E "( \\(new\\)| \\(gone\\)|premake)" | wc -l`')
		p.outln('if [ $count -ne 0 ]')
		p.outln('then')
		indent = '    '
	end
	p.outln(indent .. p.esc(path.getrelative(root_path, _PREMAKE_COMMAND)) .. ' --file=' .. p.esc(path.getrelative(root_path, _MAIN_SCRIPT)) .. ' ' .. table.concat(p.esc(args), ' '))
	if mode == 'OnNewFiles' then
		p.outln('fi')
	end
	p.outln('')
end

---
-- Generate .git/hooks/post-checkout according to mode
---
function m.gitHookInstallation()
	local git_integration_mode = p.api.rootContainer().gitintegration or "Off"
	if git_integration_mode == "Off" then
		return
	end
	local root_path = find_git_root()

	local content = p.capture(function () print_git_post_checkout_hooks(root_path, git_integration_mode) end)
	local res, err = os.writefile_ifnotequal(content, path.join(root_path, '.git', 'hooks', 'post-checkout'))

	if (res == 0) then -- file not modified
		return
	elseif (res < 0) then
		error(err, 0)
	elseif (res > 0) then -- file modified
		printf("Generated %s...", path.getrelative(os.getcwd(), path.join(root_path, '.git', 'hooks', 'post-checkout')))
		return
	end
end

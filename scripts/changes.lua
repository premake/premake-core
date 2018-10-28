---
-- Output a list of merged PRs since last release in the CHANGES.txt format
---

local format_separator = "||"

local git_command_raw = 'git log '..
						'%s/master "^%s/release" '..
						'--merges --first-parent '..
						'--pretty="%%s%s%%b" '..
						'--grep="Merge pull request #"'

local changes_pr_format = "* PR #%s %s (@%s)"

local function parse_log(line)
    change = {}
    for chunk in line:gmatch(string.format("[^%s]+", format_separator)) do
    	table.insert(change, chunk)
    end
    assert(#change == 2)

    local _, _, pr_num = change[1]:find("%s#([%d]+)%s")
    local _, _, pr_author = change[1]:find("from%s([^/]+)")
    local pr_desc = change[2]

    return {
    	number = tonumber(pr_num),
    	author = pr_author,
    	description = pr_desc
	}
end

local function gather_changes()
	local git_command = git_command_raw:format(_OPTIONS["remote"], _OPTIONS["remote"], format_separator)
	local output = os.outputof(git_command)

	changes = {}

	for line in output:gmatch("[^\r\n]+") do
		table.insert(changes, parse_log(line))
	end

	return changes
end

local function format_to_changes(changes)

	changes_copy = changes
	local function compare_changes(a, b)
		return a.number < b.number
	end
	table.sort(changes, compare_changes)

	for _, change in pairs(changes_copy) do
		print(string.format(changes_pr_format, change.number, change.description, change.author))
	end
end

local function generate_changes()
	changes = gather_changes()

	format_to_changes(changes)
end

newaction {
	trigger = "changes",
	description = "Generate a file containing merged pull requests in CHANGES.txt format",
	execute = generate_changes
}

newoption {
   trigger     = "remote",
   value       = "remoteName",
   description = "Git remote to operate on.",
   default     = "origin",
}

---
-- Check the command line arguments, and show some help if needed.
---
	local usage = 'usage is: --file=<path to this scripts/changes.lua> changes'

	if #_ARGS ~= 0 then
		error(usage, 0)
	end

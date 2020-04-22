---
-- Output a list of merged PRs since last release in the CHANGES.txt format.
---

local usage = "Usage: premake5 --file=scripts/changes.lua --since=<rev> changes"

local sinceRev = _OPTIONS["since"]

if not sinceRev then
	print(usage)
	error("Missing `--since`", 0)
end


local function parsePullRequestId(line)
	return line:match("#%d+%s")
end

local function parseTitle(line)
	return line:match("||(.+)")
end

local function parseAuthor(line)
	return line:match("%s([^%s]-)/")
end

local function parseLog(line)
	local pr = parsePullRequestId(line)
	local title = parseTitle(line)
	local author = parseAuthor(line)
	return string.format("* PR %s %s (@%s)", pr, title, author)
end


local function gatherChanges()
	local cmd = string.format('git log HEAD "^%s" --merges --first-parent --format="%%s||%%b"', _OPTIONS["since"])
	local output = os.outputof(cmd)

	changes = {}

	for line in output:gmatch("[^\r\n]+") do
		table.insert(changes, parseLog(line))
	end

	return changes
end


local function generateChanges()
	local changes = gatherChanges()
	table.sort(changes)
	for i = 1, #changes do
		print(changes[i])
	end
end


newaction {
	trigger = "changes",
	description = "Generate list of git merges in CHANGES.txt format",
	execute = generateChanges
}

newoption {
	trigger = "since",
	value = "revision",
	description = "Log merges since this revision"
}


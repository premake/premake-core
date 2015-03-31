--
-- Merge the current working branch to Premake's release branch,
-- update the embedded version number and tag the result.
--


--
-- Helper function: run a command while hiding its output.
--

	local function execQuiet(cmd, ...)
		cmd = string.format(cmd, ...) .. " > _output_.log 2> _error_.log"
		local z = os.execute(cmd)
		os.remove("_output_.log")
		os.remove("_error_.log")
		return z
	end


--
-- Check the command line arguments, and show some help if needed.
--

	local usage = 'usage is: release <version>\n' ..
		'       <version> is of the form "5.0", "5.0.1", or "5.0-rc1"\n'

	local usage = 'usage is: release <version>\n'
	if #_ARGS ~= 1 then
		error(usage, 0)
	end

	local version = _ARGS[1]


--
-- Make sure I've got what I've need to be happy.
--

	local required = { "hg" }
	for _, value in ipairs(required) do
		local z = execQuiet("%s --version", value)
		if z ~= 0 then
			error("required tool '" .. value .. "' not found", 0)
		end
	end


--
-- Figure out what I'm doing.
--

	os.chdir("..")
	local branch = os.outputof("hg branch"):gsub("%s+$", "")


--
-- Make sure I'm sure.
--

	printf("")
	printf("I am about to")
	printf("  ...merge %s to the release branch", branchName)
	printf("  ...update the embedded version to \"%s\"", version)
	printf("  ...commit and tag the merged result")
	printf("")
	printf("Does this look right to you? If so, press [Enter] to begin.")
	io.read()


--
-- Pull down the release branch.
--

	print("Preparing release folder")

	os.mkdir("release")
	os.chdir("release")
	os.rmdir(version)

	print("Cloning source code")
	local z = os.executef("hg clone .. -r release %s", branch, version)
	if z ~= 0 then
		error("clone failed", 0)
	end


--
-- Merge in the release working branch.
--

	error("merge of release working branch is not yet implemented")


--
-- Update the version number in premake.c
--

	print("Updating version number...")

	os.chdir(version)
	io.input("src/host/premake.c")
	local text = io.read("*a")
	text = text:gsub("HEAD", version)
	io.output("src/host/premake.c")
	io.write(text)
	io.close()


--
-- Commit and tag merged revision.
--

	error("commit and tag of merged branch is not yet implemented")

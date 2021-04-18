---
-- Create a source or binary release package.
---


---
-- Helper function: run a command while hiding its output.
---

	local function execQuiet(cmd, ...)
		cmd = string.format(cmd, ...) .. " > _output_.log 2> _error_.log"
		local z = os.execute(cmd)
		os.remove("_output_.log")
		os.remove("_error_.log")
		return z
	end


---
-- Check the command line arguments, and show some help if needed.
---

	local allowedCompilers = {}

	if os.ishost("windows") then
		allowedCompilers = {
			"vs2019",
			"vs2017",
			"vs2015",
			"vs2013",
			"vs2012",
			"vs2010",
			"vs2008",
			"vs2005",
		}
	elseif os.ishost("linux") or os.ishost("bsd") then
		allowedCompilers = {
			"gcc",
			"clang",
		}
	elseif os.ishost("macosx") then
		allowedCompilers = {
			"clang",
		}
	else
		error("Unsupported host os", 0)
	end

	local usage = 'usage is: package <branch> <type> [<compiler>]\n' ..
		'       <branch> is the name of the release branch to target\n' ..
		'       <type> is one of "source" or "binary"\n' ..
		'       <compiler> (default: ' .. allowedCompilers[1] .. ') is one of ' .. table.implode(allowedCompilers, "", "", " ")

	if #_ARGS ~= 2 and #_ARGS ~= 3 then
		error(usage, 0)
	end

	local branch = _ARGS[1]
	local kind = _ARGS[2]
	local compiler = _ARGS[3] or allowedCompilers[1]

	if kind ~= "source" and kind ~= "binary" then
		print("Invalid package kind: "..kind)
		error(usage, 0)
	end

	if not table.contains(allowedCompilers, compiler) then
		print("Invalid compiler: "..compiler)
		error(usage, 0)
	end

	local compilerIsVS = compiler:startswith("vs")

--
-- Make sure I've got what I've need to be happy.
--

	local required = { "git" }

	if not compilerIsVS then
		table.insert(required, "make")
		table.insert(required, compiler)
	end

	for _, value in ipairs(required) do
		local z = execQuiet("%s --version", value)
		if not z then
			error("required tool '" .. value .. "' not found", 0)
		end
	end


--
-- Figure out what I'm making.
--

	os.chdir("..")
	local text = os.outputof(string.format('git show %s:src/host/premake.h', branch))
	local _, _, version = text:find('VERSION%s*"([%w%p]+)"')

	local pkgName = "premake-" .. version
	local pkgExt = ".zip"
	if kind == "binary" then
		pkgName = pkgName .. "-" .. os.host()
		if not os.istarget("windows") then
			pkgExt = ".tar.gz"
		end
	else
		pkgName = pkgName .. "-src"
	end


--
-- Make sure I'm sure.
--

	printf("")
	printf("I am about to create a %s package", kind:upper())
	printf("  ...named release/%s%s", pkgName, pkgExt)
	printf("  ...from the %s branch", branch)
	printf("")
	printf("Does this look right to you? If so, press [Enter] to begin.")
	io.read()


--
-- Pull down the release branch.
--

	print("Preparing release folder")
	os.mkdir("release")
	os.chdir("release")
	os.rmdir(pkgName)

	print("Cloning source code")
	local z = execQuiet("git clone .. %s -b %s --recurse-submodules --depth 1 --shallow-submodules", pkgName, branch)
	if not z then
		error("clone failed", 0)
	end

	os.chdir(pkgName)

--
-- Bootstrap Premake in the newly cloned repository
--

	print("Bootstrapping Premake...")
	if compilerIsVS then
		z = os.execute("Bootstrap.bat " .. compiler)
	else
		z = os.execute("make -j -f Bootstrap.mak " .. os.host())
	end
	if not z then
		error("Failed to Bootstrap Premake", 0)
	end
	local premakeBin = path.translate("./bin/release/premake5")


--
-- Make absolutely sure the embedded scripts have been updated
--

	print("Updating embedded scripts...")

	local z = execQuiet("%s embed %s", premakeBin, iif(kind == "source", "", "--bytecode"))
	if not z then
		error("failed to update the embedded scripts", 0)
	end


--
-- Generate a source package.
--

if kind == "source" then

	local function	genProjects(parameters)
		if not execQuiet("%s %s", premakeBin, parameters) then
			error("failed to generate project for "..parameters, 0)
		end
	end

	os.rmdir("build")

	print("Generating project files...")

	local ignoreActions = {
		"clean",
		"embed",
		"package",
		"self-test",
		"test",
		"gmake", -- deprecated
	}

	local perOSActions = {
		"gmake2",
		"codelite"
	}

	for action in premake.action.each() do

		if not table.contains(ignoreActions, action.trigger) then
			if table.contains(perOSActions, action.trigger) then

				local osList = {
					{ "windows", },
					{ "unix", "linux" },
					{ "macosx", },
					{ "bsd", },
				}

				for _, os in ipairs(osList) do
					local osTarget = os[2] or os[1]
					genProjects(string.format("--to=build/%s.%s --os=%s %s", action.trigger, os[1], osTarget, action.trigger))
				end
			else
				genProjects(string.format("--to=build/%s %s", action.trigger, action.trigger))
			end
		end
	end

	print("Creating source code package...")

	local	excludeList = {
		".gitignore",
		".gitattributes",
		".gitmodules",
		".travis.yml",
		".editorconfig",
		"appveyor.yml",
		"Bootstrap.*",
		"packages/*",
	}
	local	includeList = {
		"build",
		"src/scripts.c",
	}

	if	not execQuiet("git rm --cached -r -f --ignore-unmatch "..table.concat(excludeList, ' ')) or
		not execQuiet("git add -f "..table.concat(includeList, ' ')) or
		not execQuiet("git stash") or
		not execQuiet("git archive --format=zip -9 -o ../%s.zip --prefix=%s/ stash@{0}", pkgName, pkgName) or
		not execQuiet("git stash drop stash@{0}")
	then
		error("failed to archive release", 0)
	end

	os.chdir("..")
end


--
-- Create a binary package for this platform. This step requires a working
-- GNU/Make/GCC environment.
--

if kind == "binary" then

	print("Building binary...")

	os.chdir("bin/release")

	local addCommand = "git add -f premake5%s"
	local archiveCommand = "git archive --format=%s -o ../../../%s%s stash@{0} -- ./premake5%s"

	if os.ishost("windows") then
		addCommand = string.format(addCommand, ".exe")
		archiveCommand = string.format(archiveCommand, "zip -9", pkgName, pkgExt, ".exe")
	else
		addCommand = string.format(addCommand, "")
		archiveCommand = string.format(archiveCommand, "tar.gz", pkgName, pkgExt, "")
	end

	if 	not execQuiet(addCommand) or
		not execQuiet("git stash") or
		not execQuiet(archiveCommand) or
		not execQuiet("git stash drop stash@{0}")
	then
		error("failed to archive release", 0)
	end

	os.chdir("../../..")

end


--
-- Clean up
--

	-- Use RMDIR token instead of os.rmdir to force remove .git dir which has read only files
	execQuiet(os.translateCommands("{RMDIR} "..pkgName))

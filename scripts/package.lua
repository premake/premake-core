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

	local usage = 'usage is: package <branch> <type>\n' ..
		'       <branch> is the name of the release branch to target\n' ..
		'       <type> is one of "source" or "binary"\n'

	if #_ARGS ~= 2 then
		error(usage, 0)
	end

	local branch = _ARGS[1]
	local kind = _ARGS[2]

	if kind ~= "source" and kind ~= "binary" then
		error(usage, 0)
	end


--
-- Make sure I've got what I've need to be happy.
--

	local required = { "git" }

	if not os.ishost("windows") then
		table.insert(required, "make")
		table.insert(required, "cc")
	else
		if not os.getenv("VS140COMNTOOLS") then
			error("required tool 'Visual Studio 2015' not found", 0)
		end
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

	if not os.istarget("windows") and kind == "binary" then
		pkgExt = ".tar.gz"
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

	print("Bootstraping Premake...")
	if os.ishost("windows") then
		z = execQuiet("Bootstrap.bat")
	else
		local os_map = {
			linux = "linux",
			macosx = "osx",
		}
		z = execQuiet("make -j -f Bootstrap.mak %s", os_map[os.host()])
	end
	if not z then
		error("Failed to Bootstrap Premake", 0)
	end
	local premakeBin = path.translate("bin/release/Premake5")


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

	genProjects("--to=build/vs2005 vs2005")
	genProjects("--to=build/vs2008 vs2008")
	genProjects("--to=build/vs2010 vs2010")
	genProjects("--to=build/vs2012 vs2012")
	genProjects("--to=build/vs2013 vs2013")
	genProjects("--to=build/vs2015 vs2015")
	genProjects("--to=build/vs2017 vs2017")
	genProjects("--to=build/vs2019 vs2019")
	genProjects("--to=build/gmake.windows --os=windows gmake")
	genProjects("--to=build/gmake.unix --os=linux gmake")
	genProjects("--to=build/gmake.macosx --os=macosx gmake")
	genProjects("--to=build/gmake.bsd --os=bsd gmake")

	print("Creating source code package...")

	if 	not execQuiet("git add -f build") or
		not execQuiet("git stash") or
		not execQuiet("git archive --format=zip -9 -o ../%s-src.zip --prefix=%s/ stash@{0}", pkgName, pkgName) or
		not execQuiet("git stash drop stash@{0}")
	then
		error("failed to archive release", 0)
	end

	os.chdir("..")
end


--
-- Create a binary package for this platform. This step requires a working
-- GNU/Make/GCC environment. I use MinGW on Windows as it produces the
-- smallest binaries.
--

if kind == "binary" then

	print("Building binary...")

	os.chdir("bin/release")

	local addCommand = "git add -f premake5%s"
	local archiveCommand = "git archive --format=%s -o ../../../%s-%s%s stash@{0} -- ./premake5%s"

	if os.ishost("windows") then
		addCommand = string.format(addCommand, ".exe")
		archiveCommand = string.format(archiveCommand, "zip -9", pkgName, os.host(), pkgExt, ".exe")
	else
		addCommand = string.format(addCommand, "")
		archiveCommand = string.format(archiveCommand, "tar.gz", pkgName, os.host(), pkgExt, "")
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

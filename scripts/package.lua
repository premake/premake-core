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

	local required = { "git", "make", "gcc", "premake5", "zip" }
	for _, value in ipairs(required) do
		local z = execQuiet("%s --version", value)
		if z ~= 0 then
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
	z = os.executef("git clone .. %s", pkgName)
	if z ~= 0 then
		error("clone failed", 0)
	end

	os.chdir(pkgName)

	z = os.executef("git checkout %s", branch)
	if z ~= 0 then
		error("unable to checkout branch " .. branch, 0)
	end

	z = os.executef("git submodule update --init")
	if z ~= 0 then
		error("unable to clone submodules", 0)
	end


--
-- Make absolutely sure the embedded scripts have been updated
--

	print("Updating embedded scripts...")
	if kind == "source" then
		z = execQuiet("premake5 embed")
	else
		z = execQuiet("premake5 --bytecode embed")
	end
	if z ~= 0 then
		error("failed to update the embedded scripts", 0)
	end


--
-- Clear out files I don't want included in any packages.
--

	print("Cleaning up the source tree...")
	os.rmdir("packages")
	os.rmdir(".git")

	local removelist = { ".DS_Store", ".git", ".gitignore", ".gitmodules", ".travis.yml", ".editorconfig", "appveyor.yml", "Bootstrap.mak" }
	for _, removeitem in ipairs(removelist) do
		local founditems = os.matchfiles("**" .. removeitem)
		for _, item in ipairs(founditems) do
			os.remove(item)
		end
	end

--
-- Generate a source package.
--

if kind == "source" then

	print("Generating project files...")
	execQuiet("premake5 /to=build/vs2005 vs2005")
	execQuiet("premake5 /to=build/vs2008 vs2008")
	execQuiet("premake5 /to=build/vs2010 vs2010")
	execQuiet("premake5 /to=build/vs2012 vs2012")
	execQuiet("premake5 /to=build/vs2013 vs2013")
	execQuiet("premake5 /to=build/vs2015 vs2015")
	execQuiet("premake5 /to=build/vs2017 vs2017")
	execQuiet("premake5 /to=build/gmake.windows /os=windows gmake")
	execQuiet("premake5 /to=build/gmake.unix /os=linux gmake")
	execQuiet("premake5 /to=build/gmake.macosx /os=macosx gmake")
	execQuiet("premake5 /to=build/gmake.bsd /os=bsd gmake")

	print("Creating source code package...")
	os.chdir("..")
	execQuiet("zip -r9 %s-src.zip %s/*", pkgName, pkgName)

end


--
-- Create a binary package for this platform. This step requires a working
-- GNU/Make/GCC environment. I use MinGW on Windows as it produces the
-- smallest binaries.
--

if kind == "binary" then

	print("Building binary...")
	execQuiet("premake5 gmake")
	z = execQuiet("make config=release")
	if z ~= 0 then
		error("build failed")
	end

	os.chdir("bin/release")

	local name = string.format("%s-%s%s", pkgName, os.host(), pkgExt)
	if os.ishost("windows") then
		execQuiet("zip -9 %s premake5.exe", name)
	else
		execQuiet("tar czvf %s premake5", name)
	end

	os.copyfile(name, path.join("../../../", name))
	os.chdir("../../..")

end


--
-- Clean up
--

	os.rmdir(pkgName)

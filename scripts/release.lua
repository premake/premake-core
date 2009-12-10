--
-- Prepare a new Premake release. This is still incomplete and some manual
-- work is needed to get everything packaged up.
--


function dorelease()
	local z
	local svnroot = "https://premake.svn.sourceforge.net/svnroot/premake"

-- 
-- Helper function: runs a command (formatted, with optional arguments) and
-- suppresses any output. Works on both Windows and POSIX. Might be a good
-- candidate for a core function.
--

	local function exec(cmd, ...)
		cmd = string.format(cmd, unpack(arg))
		local z = os.execute(cmd .. " > output.log 2> error.log")
		os.remove("output.log")
		os.remove("error.log")
		return z
	end


	
--
-- Make sure a version was specified
--

	if #_ARGS ~= 2 then
		error("** Usage: release [version] [source | binary]", 0)
	end
	
	local version = _ARGS[1]
	local kind = _ARGS[2]


--
-- Create a directory to hold the release
--

	local workdir = "premake-" .. version
	os.mkdir("release/" .. workdir)
	os.chdir("release/" .. workdir)

	
--
-- Look for required utilities
--

	local required = { "svn", "zip", "tar", "make", "gcc" }
	for _, value in ipairs(required) do
		z = exec("%s --version", value)
		if z ~= 0 then
			error("** '" .. value .. "' not found", 0)
		end
	end


--
-- Pre-release checklist
--

	print("")
	print("Have you...")
	print("* Updated the CHANGELOG?")
	print("* Run tests on Windows and POSIX?")
	print("* Updated the embedded scripts?")
	print("* Checked in all changes?")
	print("")
	print("Press [Enter] to begin.")
	io.read()


--
-- Look for a release branch in Subversion; create one if necessary
--

	print("Checking for release branch...")

	local branch = string.format("%s/branches/%s", svnroot, version)
	z = exec("svn ls %s", branch)
	if z ~= 0 then
		print("Creating release branch...")
		z = exec('svn cp %s/trunk %s -m "Branched for %s release"', svnroot, branch, version)
		if z ~= 0 then
			error("** Failed to create release branch.", 0)
		end
	end

	
--
-- Check out the release branch
--

	print("Checking out release branch...")

	z = exec("svn export --force %s .", branch)
	if z ~= 0 then
		error("** Failed to checkout release branch", 0)
	end


--
-- Update the version number in premake.c
--

	print("Updating version number...")

    io.input("src/host/premake.c")
    local text = io.read("*a")
	text = text:gsub("SVN", version)
    io.output("src/host/premake.c")
    io.write(text)
    io.close()


--
-- Make absolutely sure the embedded scripts have been updated
--

	print("Updating embedded scripts...")

	z = exec("premake4 embed")
	if z ~= 0 then
		error("** Failed to update the embedded scripts", 0)
	end


--
-- Generate source packaging
--

	if kind == "source" then

	--
	-- Remove extra directories
	--

		print("Cleaning up the source tree...")

		os.rmdir("samples")
		os.rmdir("packages")

	
	--
	-- Generate project files to the build directory
	--

		print("Generating project files...")
		exec("premake4 /to=build/vs2005 vs2005")
		exec("premake4 /to=build/vs2008 vs2008")
		exec("premake4 /to=build/gmake.windows /os=windows gmake")
		exec("premake4 /to=build/gmake.unix /os=linux gmake")
		exec("premake4 /to=build/gmake.macosx /os=macosx /platform=universal32 gmake")
		exec("premake4 /to=build/codeblocks.windows /os=windows codeblocks")
		exec("premake4 /to=build/codeblocks.unix /os=linux codeblocks")
		exec("premake4 /to=build/codeblocks.macosx /os=macosx /platform=universal32 codeblocks")
		exec("premake4 /to=build/codelite.windows /os=windows codelite")
		exec("premake4 /to=build/codelite.unix /os=linux codelite")
		exec("premake4 /to=build/codelite.macosx /os=macosx /platform=universal32 codelite")
		exec("premake4 /to=build/xcode3 /platform=universal32 xcode3")


	--
	-- Create source package
	--

		print("Creating source code package...")

		os.chdir("..")
		exec("zip -r9 %s-src.zip %s/*", workdir, workdir)

--
-- Create a binary package for this platform. This step requires a working
-- GNU/Make/GCC environment. I use MinGW on Windows.
--

	else
	
		print("Building platform binary release...")

		exec("premake4 /platform=universal32 gmake")
		exec("make config=%s", iif(os.is("macosx"), "releaseuniv32", "release"))

		local fname
		os.chdir("bin/release")
		if os.is("windows") then
			fname = string.format("%s-windows.zip", workdir)
			exec("zip -9 %s premake4.exe", fname)
		else
			fname = string.format("%s-%s.tar.gz", workdir, os.get())
			exec("tar czvf %s premake4", fname)
		end

		os.copyfile(fname, "../../../" .. fname)
		os.chdir("../../..")
	end


--
-- Upload files to SourceForge
--



--
-- Clean up
--
	
	
--
-- Remind me of required next steps
--

	print("")
	print("Finished. Now...")
	print("* Upload packages to SourceForge and create release")
	print("* Write news post and publish to front page")
	print("* Post to Twitter")
	print("* Post to email list")
	print("* Update Freshmeat")
	print("* Post news item on SourceForge")
	print("* Copy binaries to local path")

end

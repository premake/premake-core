--
-- Prepare a new Premake release. This is still incomplete and some manual
-- work is needed to get everything packaged up.
--

function dorelease()
	local z
	local svnroot = "https://premake.svn.sourceforge.net/svnroot/premake"
	
--
-- Make sure a version was specified
--

	if #_ARGS == 0 then
		error("** You must specify a version number", 0)
	end
	

--
-- Look for required utilities
--

	local required = { "svn", "zip", "tar", "make", "gcc" }
	for _, cmd in ipairs(required) do
		z = os.executef("%s --version &> release.log", cmd)
		if z ~= 0 then
			error("** '" .. cmd .. "' not found", 0)
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
-- Create a directory to hold releases
--

	os.mkdir("release")
	os.chdir("release")
	
	
--
-- Look for a release branch in Subversion; create one if necessary
--

	print("Checking for release branch...")
	local branch = string.format("%s/branches/%s", svnroot, _ARGS[1])
	z = os.executef("svn ls %s &> release.log", branch)
	if z ~= 0 then
		print("Creating release branch...")
		z = os.executef('svn cp %s/trunk %s -m "Branched for %s release" > release.log', svnroot, branch, _ARGS[1])
		if z ~= 0 then
			error("** Failed to create release branch.", 0)
		end
	end

	
--
-- Check out the release branch
--

	print("Checking out release branch...")
	local branchdir = "premake-" .. _ARGS[1]
	z = os.executef("svn co %s %s &> release.log", branch, branchdir)
	if z ~= 0 then
		error("** Failed to checkout release branch", 0)
	end
	os.chdir(branchdir)


--
-- Update the version number in premake.c
--

	print("Updating version number...")
    io.input("src/host/premake.c")
    local text = io.read("*a")
	text = text:gsub("SVN", _ARGS[1])
    io.output("src/host/premake.c")
    io.write(text)
    io.close()


--
-- Make absolutely sure the embedded scripts have been updated
--

	print("Updating embedded scripts...")
	z = os.executef("premake4 embed &> ../release.log")
	if z ~= 0 then
		error("** Failed to update the embedded scripts", 0)
	end


--
-- If anything changed in those last two steps, check it in to the branch
--

	print("Committing changes...")
	z = os.executef('svn commit -m "Updated version and scripts" &> ../release.log')
	if z ~= 0 then
		error("** Failed to commit changes", 0)
	end


--
-- Right now I only generate the source packaging under Mac OS X
--

	if os.is("macosx") then

	--
	-- Remove .svn, samples, and packages directories
	--

		print("Cleaning up the source tree...")
		z = os.executef("rm -rf `find . -name .svn`")
		if z ~= 0 then
			error("** Failed to remove .svn directories", 0)
		end

		z = os.executef("rm -rf samples")
		if z ~= 0 then
			error("** Failed to remove samples directories", 0)
		end	

		z = os.executef("rm -rf packages")
		if z ~= 0 then
			error("** Failed to remove samples directories", 0)
		end	
	
	--
	-- Generate project files to the build directory
	--

		print("Generating project files...")
		os.executef("premake4 /to=build/vs2005 vs2005 &> ../release.log")
		os.executef("premake4 /to=build/vs2008 vs2008 &> ../release.log")
		os.executef("premake4 /to=build/gmake.windows /os=windows gmake &> ../release.log")
		os.executef("premake4 /to=build/gmake.unix /os=linux gmake &> ../release.log")
		os.executef("premake4 /to=build/gmake.macosx /os=macosx /platform=universal32 gmake &> ../release.log")
		os.executef("premake4 /to=build/codeblocks.windows /os=windows codeblocks &> ../release.log")
		os.executef("premake4 /to=build/codeblocks.unix /os=linux codeblocks &> ../release.log")
		os.executef("premake4 /to=build/codeblocks.macosx /os=macosx /platform=universal32 codeblocks &> ../release.log")
		os.executef("premake4 /to=build/codelite.windows /os=windows codelite &> ../release.log")
		os.executef("premake4 /to=build/codelite.unix /os=linux codelite &> ../release.log")
		os.executef("premake4 /to=build/codelite.macosx /os=macosx /platform=universal32 codelite &> ../release.log")
		os.executef("premake4 /to=build/xcode3 /platform=universal32 xcode3 &> ../release.log")

	--
	-- Create source package
	--

		print("Creating source code package...")
		os.chdir("..")
		os.executef("zip -r9 %s-src.zip %s/* &> ../release.log", branchdir, branchdir)
		os.chdir(branchdir)

	end


--
-- Create a binary package for this platform. This step requires a working
-- GNU/Make/GCC environment. I use MinGW on Windows.
--

	print("Building platform binary release...")
	local fname = string.format("%s-%s", branchdir, os.get())

	os.chdir("build/gmake." .. os.get())
	os.executef("make config=%s &> ../../../release.log", iif(os.is("macosx"), "releaseuniv32", "release"))

	os.chdir("../../bin/release")
	if os.is("windows") then
		os.executef("zip -9 %s.zip premake4.exe &> ../../../release.log", fname)
		os.executef("move %s.zip ../../.. &> ../../../release.log", fname)
	else
		os.executef("tar czvf %s.tar.gz premake4 &> ../../../release.log", fname)
		os.executef("mv %s.tar.gz ../../.. &> ../../../release.log", fname)
	end


--
-- Upload files to SourceForge
--

	os.chdir("../..")

--
-- Clean up
--

	os.chdir("..")
	os.remove("release.log")
	
	
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

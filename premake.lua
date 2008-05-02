project.name = "Premake4"

-- Project options

	addoption("no-tests", "Build without automated tests")


-- Output directories

	project.config["Debug"].bindir = "bin/debug"
	project.config["Release"].bindir = "bin/release"

  
-- Packages

	dopackage("src")


-- Cleanup code

	function doclean(cmd, arg)
		docommand(cmd, arg)
		os.rmdir("bin")
		os.rmdir("doc")
	end


-- Release code

	REPOS    = "https://premake.svn.sourceforge.net/svnroot/premake"
	TRUNK    = "/trunk"
	BRANCHES = "/branches/4.0-alpha/"

	function dorelease(cmd, arg)
		
		if (not arg) then
			error "You must specify a version"
		end

		-------------------------------------------------------------------
		-- Make sure everything is good before I start
		-------------------------------------------------------------------
		print("")
		print("PRE-FLIGHT CHECKLIST")
		print(" * is README up-to-date?")
		print(" * is CHANGELOG up-to-date?")
		print(" * did you test build with GCC?")
		print(" * did you test build with Doxygen?")
		print(" * are 'svn' (all) and '7z' (Windows) available?")
		print("")
		print("Press [Enter] to continue or [^C] to quit.")
		io.stdin:read("*l")

		-------------------------------------------------------------------
		-- Set up environment
		-------------------------------------------------------------------
		local version = arg
		
		os.mkdir("releases")

		local folder  = "premake-"..version
		local trunk   = REPOS..TRUNK
		local branch  = REPOS..BRANCHES..version
		
		-------------------------------------------------------------------
		-- Build and run all automated tests on working copy
		-------------------------------------------------------------------
		print("Building tests on working copy...")
		os.execute("premake --target gnu >releases/release.log")
		result = os.execute("make CONFIG=Release >releases/release.log")
		if (result ~= 0) then
			error("Test build failed; see release.log for details")
		end

		-------------------------------------------------------------------
		-- Look for a release branch in SVN, and create one from trunk if necessary		
		-------------------------------------------------------------------
		print("Checking for release branch...")
		os.chdir("releases")
		result = os.execute(string.format("svn ls %s >release.log 2>&1", branch))
		if (result ~= 0) then
			print("Creating release branch...")
			result = os.execute(string.format('svn copy %s %s -m "Creating release branch for %s" >release.log', trunk, branch, version))
			if (result ~= 0) then
				error("Failed to create release branch at "..branch)
			end
		end

		-------------------------------------------------------------------
		-- Checkout a local copy of the release branch
		-------------------------------------------------------------------
		print("Getting source code from release branch...")
		os.execute(string.format("svn co %s %s >release.log", branch, folder))
		if (not os.fileexists(folder.."/README.txt")) then
			error("Unable to checkout from repository at "..branch)
		end

		-------------------------------------------------------------------
		-- Embed version numbers into the files
		-------------------------------------------------------------------
		-- (embed version #s)
		-- (check into branch)

		-------------------------------------------------------------------
		-- Build the release binary for this platform
		-------------------------------------------------------------------
		print("Building release version...")
		os.chdir(folder)
		os.execute("premake --clean --no-tests --target gnu >../release.log")
		os.execute("make CONFIG=Release >../release.log")
		
		if (windows) then
			result = os.execute(string.format("7z a -tzip ..\\premake-win32-%s.zip bin\\release\\premake4.exe >../release.log", version))
		elseif (macosx) then
			result = os.execute(string.format("tar czvf ../premake-macosx-%s.tar.gz bin/release/premake4 >../release.log", version))
		else
			result = os.execute(string.format("tar czvf ../premake-linux-%s.tar.gz bin/release/premake4 >../release.log", version))
		end
		
		if (result ~= 0) then
			error("Failed to build binary package; see release.log for details")
		end

		-------------------------------------------------------------------
		-- Clean up
		-------------------------------------------------------------------
		print("Cleaning up...")
		os.chdir("..")
		os.rmdir(folder)
		os.remove("release.log")


		-------------------------------------------------------------------
		-- Next steps
		-------------------------------------------------------------------
		if (windows) then
			print("DONE - now run release script under Linux")
		elseif (linux) then
			print("DONE - now run release script under Mac OS X")
		else
			print("DONE - really this time")
		end
		
	end
	

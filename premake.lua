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

	REPOS = "file://.psf/.Mac/Users/jason/Svn/Premake"
	TRUNK    = "/trunk"
	BRANCHES = "/branches/4.0-alpha/"
	
	function userinput(prompt)
		if (prompt) then print(prompt) end
		io.stdout:write("> ")
		local value = io.stdin:read("*l")
		print("")
		return value
	end
	
	function dobuildrelease(cmd, arg)
		os.mkdir("releases")
		os.chdir("releases")

		-------------------------------------------------------------------
		-- TODO: get the version from the command line instead
		-------------------------------------------------------------------
		local version = userinput("What is the version number for this release?")
		
		local folder  = "premake-"..version
		local trunk   = REPOS..TRUNK
		local branch  = REPOS..BRANCHES..version
		
		-------------------------------------------------------------------
		-- Make sure everything is good before I start
		-------------------------------------------------------------------
		print("")
		print("PRE-FLIGHT CHECKLIST")
		print("  * is README up-to-date?")
		print("  * is CHANGELOG up-to-date?")
		print("  * did you test build with GCC?")
		print("  * did you test run Doxygen?")
		print("  * TODO: automate test for 'svn' (all), '7z', MinGW (Windows)")
		userinput()

		-------------------------------------------------------------------
		-- Look for a release branch in SVN, and create one from trunk if necessary		
		-------------------------------------------------------------------
		print("Checking for release branch...")
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
		-- Build and run all automated tests
		-------------------------------------------------------------------
		print("Building test version...")
		os.chdir(folder)
		os.execute("premake --target gnu > ../release.log")
		result = os.execute("make CONFIG=Release >../release.log")
		if (result ~= 0) then
			error("Test build failed; see release.log for details")
		end

		-------------------------------------------------------------------
		-- Embed version numbers into the files
		-------------------------------------------------------------------
		print("TODO - set version number in premake")

		-------------------------------------------------------------------
		-- Build the release binary for this platform
		-------------------------------------------------------------------
		print("Building release version...")
		os.execute("premake --clean --no-tests --target gnu >../release.log")
		os.execute("make CONFIG=Release >../release.log")
		
		if (windows) then
			result = os.execute(string.format("7z a -tzip ..\\premake-win32-%s.zip bin\\release\\premake4.exe >../release.log", version))
		elseif (macosx) then
			error("OSX not done yet")
		else
			error("Linux not done yet")
		end
		
		if (result ~= 0) then
			error("Failed to build binary package; see release.log for details")
		end

		print("Cleaning up...")
		os.chdir("..")
		os.rmdir(folder)
		os.remove("release.log")
				
	end
	

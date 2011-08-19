--
-- Prepare a new Premake release. This is still incomplete and some manual
-- work is needed to get everything packaged up. See RELEASE.txt in this
-- folder for the full checklist.
--  
-- Info on using Mercurial to manage releases:
--  http://hgbook.red-bean.com/read/managing-releases-and-branchy-development.html
--  http://stevelosh.com/blog/2009/08/a-guide-to-branching-in-mercurial/
--


function dorelease()
	local z

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
	
    local pkgname = "premake-" .. version


--
-- Look for required utilities
--

	local required = { "hg", "make", "gcc" }
	for _, value in ipairs(required) do
		z = exec("%s --version", value)
		if z ~= 0 then
			error("** '" .. value .. "' not found", 0)
		end
	end


--
-- Pre-release checklist
--

   print( "")
   print( "BEFORE RUNNING THIS SCRIPT follow the checklist in RELEASE.txt" )
   print( "")
   print( "Press [Enter] to begin.")
   io.read()





---------------------------------------------------------------------------
--
-- Everything below this needs to be reworked for Mercurial
--
---------------------------------------------------------------------------

-- 
-- Check out the release tagged sources to releases/
--

	print("Downloading release tag...")
	
	os.mkdir("release")
	os.chdir("release")
	
	os.rmdir(pkgname)
	z = exec( "hg clone -r %s .. %s", version, pkgname)
	if z ~= 0 then
		error("** Failed to download tagged sources", 0)
	end
	
	os.chdir(pkgname)


--
-- Update the version number in premake.c
--

	print("Updating version number...")

	io.input("src/host/premake.c")
	local text = io.read("*a")
	text = text:gsub("HEAD", version)
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
		os.rmdir(".hg")
		os.rmdir(".hgignore")
		os.rmdir(".hgtags")

	
	--
	-- Generate project files to the build directory
	--

		print("Generating project files...")
		
		exec("premake4 /to=build/vs2005 vs2005")
		exec("premake4 /to=build/vs2008 vs2008")
		exec("premake4 /to=build/vs2010 vs2010")
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
		exec("zip -r9 %s-src.zip %s/*", pkgname, pkgname)

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
			fname = string.format("%s-windows.zip", pkgname)
			exec("zip -9 %s premake4.exe", fname)
		else
			fname = string.format("%s-%s.tar.gz", pkgname, os.get())
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
	
	os.rmdir(pkgname)
	
	print("")
	print( "Finished.")

end

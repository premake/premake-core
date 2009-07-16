--
-- Prepare a new Premake release. This is still incomplete and some manual
-- work is needed to get everything packaged up.
--

local function executef(cmd, ...)
	cmd = string.format(cmd, unpack(arg))
	os.execute(cmd)
end


function dorelease()

--
-- Make sure a version was specified
--

	if #_ARGS == 0 then
		error("** You must specify a version number", 0)
	end
	
	
--
-- Look for a release branch in Subversion; create one if necessary
--


--
-- Check out the release branch
--


--
-- Update the version number in premake.c
--


--
-- Make absolutely sure the embedded scripts have been updated
--


--
-- If anything changed in those last two steps, check it in to the branch
--


--
-- Remove .svn, samples, and packages directories
--


--
-- Generate project files to the build directory
--

	os.execute("premake4 /to=build/vs2005 vs2005")
	os.execute("premake4 /to=build/vs2008 vs2008")
	os.execute("premake4 /to=build/gmake.windows /os=windows gmake")
	os.execute("premake4 /to=build/gmake.unix /os=linux gmake")
	os.execute("premake4 /to=build/gmake.macosx /os=macosx /platform=universal32 gmake")
	os.execute("premake4 /to=build/codeblocks.windows /os=windows codeblocks")
	os.execute("premake4 /to=build/codeblocks.unix /os=linux codeblocks")
	os.execute("premake4 /to=build/codeblocks.macosx /os=macosx /platform=universal32 codeblocks")
	os.execute("premake4 /to=build/codelite.windows /os=windows codelite")
	os.execute("premake4 /to=build/codelite.unix /os=linux codelite")
	os.execute("premake4 /to=build/codelite.macosx /os=macosx /platform=universal32 codelite")
	

--
-- Create a source package
--

	if os.is("macosx") then
		local fname = "premake-" .. _ARGS[1]
		os.chdir("..")
		executef("zip -r9 %s-src.zip %s/*", fname, fname)
		executef("mv %s-src.zip %s", fname, fname)
		os.chdir(fname)
	end


--
-- Create a binary package for this platform. This step requires a working
-- GNU/Make/GCC environment. I use MinGW on Windows.
--

	local fname = string.format("premake-%s-%s", _ARGS[1], os.get())

	os.chdir("build/gmake." .. os.get())
	os.execute("make config=" .. iif(os.is("macosx"), "releaseuniv32", "release"))

	os.chdir("../../bin/release")
	if os.is("windows") then
		executef("7z -tzip a %s.zip premake4.exe", fname)
		executef("move %s.zip ../..", fname)
	else
		executef("tar czvf %s.tar.gz premake4", fname)
		executef("mv %s.tar.gz ../..", fname)
	end
	
	

--
-- Upload files to SourceForge
--


--
-- Remind me of required next steps
--

end

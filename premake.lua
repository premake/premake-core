if (target == "vs2002" or target == "vs2003") then
	error(
		"\nBecause of compiler limitations, Visual Studio 2002 and 2003 aren't able to\n" ..
		"build this version of Premake. Use the free Visual Studio Express instead.", 0)
end


project.name = "Premake4"

	project.configs = { "Release", "Debug" }
	
-- Output directories

	project.config["Debug"].bindir = "bin/debug"
	project.config["Release"].bindir = "bin/release"

  
-- Packages

	dopackage("src")


-- Cleanup code

	function doclean(cmd, arg)
		docommand(cmd, arg)
		os.rmdir("bin")
	end

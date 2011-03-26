	
	T.gcc_linking = { }
	local suite = T.gcc_linking
	
	local staticPrj
	local linksToStaticProj
	local sln
	
	function suite.setup()
		_ACTION = "gmake"

		sln = solution "MySolution"
		configurations { "Debug" }
		platforms {}
	
		staticPrj = project "staticPrj"
		targetdir 'bar'
		language 'C++'
		kind "StaticLib"
		
		linksToStaticProj = project "linksToStaticProj"
		language 'C++'
		kind 'ConsoleApp'
		links{'staticPrj'}
	end
	
	function suite.teardown()
		staticPrj = nil
		linksToStaticProj = nil
		sln = nil
	end
	
	local get_buffer = function()
		io.capture()
		premake.buildconfigs()
		local cfg = premake.getconfig(linksToStaticProj, 'Debug', 'Native')
		premake.gmake_cpp_config(cfg, premake.gcc)
		local buffer = io.endcapture()
		return buffer
	end
	function suite.ProjectLinksToStaticPremakeMadeLibrary_linksUsingTheFormat_pathNameExtension()
		local buffer = get_buffer()
		local format_exspected = 'LIBS      %+%= bar/libstaticPrj.a'
		test.string_contains(buffer,format_exspected)
	end

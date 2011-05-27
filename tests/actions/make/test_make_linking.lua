	
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
	
	local get_buffer = function(projectName)
		io.capture()
		premake.bake.buildconfigs()
		local cfg = premake.getconfig(projectName, 'Debug', 'Native')
		premake.gmake_cpp_config(cfg, premake.gcc)
		local buffer = io.endcapture()
		return buffer
	end
	
	function suite.projectLinksToStaticPremakeMadeLibrary_linksUsingTheFormat_pathNameExtension()
		local buffer = get_buffer(linksToStaticProj)
		local format_exspected = 'LIBS      %+%= bar/libstaticPrj.a'
		test.string_contains(buffer,format_exspected)
	end

	T.link_suite= { }
	local firstProject = nil
	local linksToFirstProject = nil
	
	function T.link_suite.setup()
		_ACTION = "gmake"
		solution('dontCareSolution')
			configurations{'Debug'}
	end
	
	function T.link_suite.teardown()
		_ACTION = nil
		firstProject = nil
		linksToFirstProject = nil
	end
	
	function T.link_suite.projectLinksToSharedPremakeMadeLibrary_linksUsingFormat_dashLName()
	
		firstProject = project 'firstProject'
			kind 'SharedLib'
			language 'C'
	
		linksToFirstProject = project 'linksToFirstProject'
			kind 'ConsoleApp'
			language 'C'
			links{'firstProject'}
			
		local buffer = get_buffer(linksToFirstProject)
		local format_exspected = 'LIBS      %+%= %-lfirstProject'
		test.string_contains(buffer,format_exspected)
	end
		
	function T.link_suite.projectLinksToPremakeMadeConsoleApp_doesNotLinkToConsoleApp()
		
		firstProject = project 'firstProject'
			kind 'ConsoleApp'
			language 'C'
	
		linksToFirstProject = project 'linksToFirstProject'
			kind 'ConsoleApp'
			language 'C'
			links{'firstProject'}
			
		local buffer = get_buffer(linksToFirstProject)
		local format_exspected = 'LIBS      %+%=%s+\n'
		test.string_contains(buffer,format_exspected)
	end
	
	function T.link_suite.projectLinksToStaticPremakeMadeLibrary_projectDifferInDirectoryHeights_linksUsingCorrectRelativePath()
	
		firstProject = project 'firstProject'
			kind 'StaticLib'
			language 'C'

		linksToFirstProject = project 'linksToFirstProject'
			kind 'ConsoleApp'
			language 'C'
			links{'firstProject'}
			location './foo/bar'
			
		local buffer = get_buffer(linksToFirstProject)
		local format_exspected = 'LIBS      %+%= ../../libfirstProject.a'
		test.string_contains(buffer,format_exspected)
	end


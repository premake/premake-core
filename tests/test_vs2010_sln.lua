	T.vs2010_sln = { }

local vs_magic_cpp_build_tool_id = "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942"
local constant_uuid = "AE61726D-187C-E440-BD07-2556188A6565"
local constant_project_name = "MyProject"
--
-- Configure a solution for testing
--

	local sln
	function T.vs2010_sln.setup()
		_ACTION = "vs2010"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		prj = project(constant_project_name)
		language "C++"
		kind "ConsoleApp"
		uuid(constant_uuid)
		
		premake.buildconfigs()
	end
	
	local function escape_id(str)
		return string.gsub(str,"%-+","%%%-")	
	end
	
	local function assert_has_project(buffer,uid,name,ext)
		test.string_contains(buffer,"Project(\"{"..escape_id(vs_magic_cpp_build_tool_id).."}\") = \""..name.."\", \""..name.."."..ext.."\", \"{"..escape_id(uid).."}\"")
	end
	
	
	
	local function assert_find_uuid(buffer,id)
		test.string_contains(buffer,escape_id(id))
	end

	local function get_buffer()
		io.capture()
		premake.vs_generic_solution(sln)
		buffer = io.endcapture()
		return buffer
	end
	
	function T.vs2010_sln.action_formatVersionis11()
		local buffer = get_buffer()
		test.string_contains(buffer,'Format Version 11.00')
	end
	
	function T.vs2010_sln.action_vsIs2010()
		local buffer = get_buffer()
		test.string_contains(buffer,'# Visual Studio 2010')
	end

	function T.vs2010_sln.action_hasProjectScope()
		local buffer = get_buffer()
		test.string_contains(buffer,"Project(.*)EndProject")
	end
	
	function T.vs2010_sln.containsVsCppMagicId()
		local buffer = get_buffer()
		assert_find_uuid(buffer,vs_magic_cpp_build_tool_id)
	end

	function T.vs2010_sln.action_findMyProjectID()
		local buffer = get_buffer()
		test.string_contains(buffer,escape_id(constant_uuid))
	end
	
	function T.vs2010_sln.action_findsExtension()
		local buffer = get_buffer()
		test.string_contains(buffer,".vcxproj")
	end
	
	function T.vs2010_sln.action_hasGlobalStartBlock()
		local buffer = get_buffer()
		test.string_contains(buffer,"Global")
	end
		
	function T.vs2010_sln.action_hasGlobalEndBlock()
		local buffer = get_buffer()
		test.string_contains(buffer,"EndGlobal")
	end
	
	function T.vs2010_sln.BasicLayout()
		io.capture()
		premake.vs_generic_solution(sln)
		test.capture ('\239\187\191' .. [[

Microsoft Visual Studio Solution File, Format Version 11.00
# Visual Studio 2010
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "MyProject.vcxproj", "{AE61726D-187C-E440-BD07-2556188A6565}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Release|Win32 = Release|Win32
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.Build.0 = Release|Win32
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
EndGlobal
		]])
	end
	



	
	

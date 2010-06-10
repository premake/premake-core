	T.vs2010_vcxproj = { }
	local vs10_vcxproj = T.vs2010_vcxproj

--[[

<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|Win32">
      <Configuration>Debug</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|Win32">
      <Configuration>Release</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
  </ItemGroup>
</Project>
--]]

	local sln, prj
	function vs10_vcxproj.setup()
		_ACTION = "vs2010"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		--project "DotNetProject"   -- to test handling of .NET platform in solution
		--language "C#"
		--kind "ConsoleApp"
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"		
	end
	
	local function get_buffer()
		io.capture()
		premake.buildconfigs()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
		premake.vs2010_vcxproj(prj)
		buffer = io.endcapture()
		return buffer
	end

	function vs10_vcxproj.xmlDeclarationPresent()
		buffer = get_buffer()
		test.istrue(string.startswith(buffer, '<?xml version=\"1.0\" encoding=\"utf-8\"?>'))
	end

	function vs10_vcxproj.projectBlocksArePresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<Project*.*</Project>')
	end

	function vs10_vcxproj.projectOpenTagIsCorrect()
		buffer = get_buffer()
		test.string_contains(buffer,'<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">*.*</Project>')
	end
	
	function vs10_vcxproj.configItemGroupPresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<ItemGroup Label="ProjectConfigurations2">*.*</ItemGroup>')
	end
	
	function vs10_vcxproj.configBlocksArePresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<ProjectConfiguration*.*</ProjectConfiguration>')
	end

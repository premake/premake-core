--
-- tests/actions/vstudio/vc200x/test_assembly_refs.lua
-- Validate managed assembly references in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs200x_assembly_refs")
	local vc200x = p.vstudio.vc200x


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2005")
		wks = test.createWorkspace()
		clr "On"
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)
		vc200x.assemblyReferences(prj)
	end


--
-- If there are no managed assemblies listed in links, output nothing.
--

	function suite.noOutput_onNoAssemblies()
		prepare()
		test.isemptycapture()
	end


--
-- To distinguish between managed and unmanaged libraries, the ".dll"
-- extension must be explicitly supplied.
--

	function suite.listsAssemblies()
		links { "System.dll", "System.Data.dll" }
		prepare()
		test.capture [[
<AssemblyReference
	RelativePath="System.dll"
/>
<AssemblyReference
	RelativePath="System.Data.dll"
/>
		]]
	end


--
-- Any unmanaged libraries included in the list should be ignored.
--

	function suite.ignoresUnmanagedLibraries()
		links { "m", "System.dll" }
		prepare()
		test.capture [[
<AssemblyReference
	RelativePath="System.dll"
/>
		]]
	end


--
-- Local (non-system) assemblies can be referenced with a relative path.
--

	function suite.canReferenceLocalAssembly()
		links { "../nunit.framework.dll" }
		prepare()
		test.capture [[
<AssemblyReference
	RelativePath="..\nunit.framework.dll"
/>
		]]
	end

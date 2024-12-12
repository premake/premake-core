local p = premake
local suite = test.declare("test_android_files")
local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		system "android"
		vc2010.files(prj)
	end


--
-- Test filtering of source files into the correct categories.
--

	function suite.none_onJavaFile()
		files { "hello.java" }
		prepare()
		test.capture [[
<ItemGroup>
	<None Include="hello.java" />
</ItemGroup>
		]]
	end

	function suite.javaCompile_onJavaFile()
		kind "Packaging"
		files { "hello.java" }
		prepare()
		test.capture [[
<ItemGroup>
	<JavaCompile Include="hello.java" />
</ItemGroup>
		]]
	end

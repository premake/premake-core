--
-- test_tokens.lua
-- Generate a NuGet packages.config file.
-- Copyright (c) Jess Perkins and the Premake project
--


	local p = premake
	local suite =  test.declare("vstudio_vs2010_tokens")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")

		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		vc2010.files(prj)
	end



	function suite.customBuild_onBuildRuleMultipleBuildOutputs()
		location "projects"
		files { "hello.cg" }

		filter "files:**.cg"
			buildcommands { "cgc %{file.relpath}" }
			buildoutputs { "%{file.basename}.a", "%{file.basename}.b" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="..\hello.cg">
		<FileType>Document</FileType>
		<Command>cgc %(Identity)</Command>
		<Outputs>../hello.a;../hello.b</Outputs>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.customBuild_onBuildRuleWithMessage()
		location "projects"
		files { "hello.cg" }
		filter "files:**.cg"
			buildmessage "Compiling shader %{file.relpath}"
			buildcommands { "cgc %{file.relpath}" }
			buildoutputs { "%{file.basename}.obj" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="..\hello.cg">
		<FileType>Document</FileType>
		<Command>cgc %(Identity)</Command>
		<Outputs>../hello.obj</Outputs>
		<Message>Compiling shader %(Identity)</Message>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.customBuild_onBuildRuleWithAdditionalInputs()
		location "projects"
		files { "hello.cg" }
		filter "files:**.cg"
			buildcommands { "cgc %{file.relpath}" }
			buildoutputs { "%{file.basename}.obj" }
			buildinputs { "common.cg.inc", "common.cg.inc2" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="..\hello.cg">
		<FileType>Document</FileType>
		<Command>cgc %(Identity)</Command>
		<Outputs>../hello.obj</Outputs>
		<AdditionalInputs>../common.cg.inc;../common.cg.inc2</AdditionalInputs>
	</CustomBuild>
</ItemGroup>
		]]
	end



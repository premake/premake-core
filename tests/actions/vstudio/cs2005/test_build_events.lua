--
-- tests/actions/vstudio/cs2005/test_build_events.lua
-- Check generation of pre- and post-build commands for C# projects.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_build_events = {}
	local suite = T.vstudio_cs2005_build_events
	local cs2005 = premake.vstudio.cs2005


--
-- Setup 
--

	local sln, prj, cfg
	
	function suite.setup()
		sln = test.createsolution()
	end
	
	local function prepare(platform)
		prj = premake.solution.getproject_ng(sln, 1)
		cs2005.buildEvents(prj)
	end


--
-- If no build steps are specified, nothing should be written.
--

	function suite.noOutput_onNoEvents()
		prepare()
		test.isemptycapture()
	end


--
-- If one command set is used and not the other, only the one should be written.
--

	function suite.onlyOne_onPreBuildOnly()
		prebuildcommands { "command1" }
		prepare()
		test.capture [[
	<PropertyGroup>
		<PreBuildEvent>command1</PreBuildEvent>
	</PropertyGroup>
		]]
	end

	function suite.onlyOne_onPostBuildOnly()
		postbuildcommands { "command1" }
		prepare()
		test.capture [[
	<PropertyGroup>
		<PostBuildEvent>command1</PostBuildEvent>
	</PropertyGroup>
		]]
	end

	function suite.both_onBoth()
		prebuildcommands { "command1" }
		postbuildcommands { "command2" }
		prepare()
		test.capture [[
	<PropertyGroup>
		<PreBuildEvent>command1</PreBuildEvent>
		<PostBuildEvent>command2</PostBuildEvent>
	</PropertyGroup>
		]]
	end


--
-- Multiple commands are separated with escaped EOL characters.
--

	function suite.splits_onMultipleCommands()
		postbuildcommands { "command1", "command2" }
		prepare()
		test.capture [[
	<PropertyGroup>
		<PostBuildEvent>command1&#x0D;&#x0A;command2</PostBuildEvent>
	</PropertyGroup>
		]]
	end


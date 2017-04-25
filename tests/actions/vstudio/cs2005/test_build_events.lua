--
-- tests/actions/vstudio/cs2005/test_build_events.lua
-- Check generation of pre- and post-build commands for C# projects.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_build_events")
	local cs2005 = p.vstudio.cs2005


--
-- Setup
--

	local wks, prj, cfg

	function suite.setup()
		p.action.set("vs2005")
		p.escaper(p.vstudio.vs2010.esc)
		wks = test.createWorkspace()
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)
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
-- Multiple commands should be separated with un-escaped EOLs.
--

	function suite.splits_onMultipleCommands()
		postbuildcommands { "command1", "command2" }
		prepare()
		test.capture ("\t<PropertyGroup>\n\t\t<PostBuildEvent>command1\r\ncommand2</PostBuildEvent>\n\t</PropertyGroup>\n")
	end



--
-- Quotes should not be escaped, other special characters should.
--

	function suite.onSpecialChars()
		postbuildcommands { '\' " < > &' }
		prepare()
		test.capture [[
	<PropertyGroup>
		<PostBuildEvent>' " &lt; &gt; &amp;</PostBuildEvent>
	</PropertyGroup>
		]]
	end

--
-- tests/actions/vstudio/vc2010/test_character_set.lua
-- Validate generation Unicode/MBCS settings.
-- Copyright (c) 2011-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_character_set")
	local vc2010 = premake.vstudio.vc2010


	local wks, prj

	function suite.setup()
		_ACTION = "vs2010"
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.characterSet(cfg)
	end


	function suite.onDefault()
		prepare()
		test.capture [[
<CharacterSet>Unicode</CharacterSet>
		]]
	end


	function suite.onUnicode()
		characterset "Unicode"
		prepare()
		test.capture [[
<CharacterSet>Unicode</CharacterSet>
		]]
	end


	function suite.onMBCS()
		characterset "MBCS"
		prepare()
		test.capture [[
<CharacterSet>MultiByte</CharacterSet>
		]]
	end

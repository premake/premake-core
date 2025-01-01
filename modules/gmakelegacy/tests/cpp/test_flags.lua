--
-- tests/actions/make/cpp/test_flags.lua
-- Tests compiler and linker flags for Makefiles.
-- Copyright (c) 2012-2015 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_flags")
	local make = p.makelegacy
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare(calls)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = p.tools.gcc
		p.callArray(calls, cfg, toolset)
	end


--
-- Include directories should be relative and space separated.
--

	function suite.includeDirs()
		includedirs { "src/include", "../include" }
		prepare { make.includes }
		test.capture [[
  INCLUDES += -Isrc/include -I../include
		]]
	end


--
-- symbols "on" should produce -g
--
	function suite.symbols_on()
		symbols "on"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) -g
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS) -g
		]]
	end

--
-- symbols default to 'off'
--
	function suite.symbols_default()
		symbols "default"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS)
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS)
		]]
	end

--
-- All other symbols flags also produce -g
--
	function suite.symbols_fastlink()
		symbols "FastLink"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) -g
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS) -g
		]]
	end

	function suite.symbols_full()
		symbols "full"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) -g
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS) -g
		]]
	end

--
-- symbols "off" should not produce -g
--
	function suite.symbols_off()
		symbols "off"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS)
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS)
		]]
	end

--
-- symbols "on" with a proper debugformat should produce a corresponding -g
--
	function suite.symbols_on_default()
		symbols "on"
		debugformat "Default"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) -g
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS) -g
		]]
	end

	function suite.symbols_on_dwarf()
		symbols "on"
		debugformat "Dwarf"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) -gdwarf
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS) -gdwarf
		]]
	end

	function suite.symbols_on_split_dwarf()
		symbols "on"
		debugformat "SplitDwarf"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) -gsplit-dwarf
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS) -gsplit-dwarf
		]]
	end

--
-- symbols "off" with a proper debugformat should not produce -g
--
	function suite.symbols_off_dwarf()
		symbols "off"
		debugformat "Dwarf"
		prepare { make.cFlags, make.cxxFlags }
		test.capture [[
  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS)
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS)
		]]
	end

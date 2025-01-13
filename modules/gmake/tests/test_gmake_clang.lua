--
-- test_gmake_clang.lua
-- Test Clang support in Makefiles.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake_clang")

	local p = premake
	local gmake = p.modules.gmake

--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks = test.createWorkspace()
		toolset "clang"
		prj = p.workspace.getproject(wks, 1)
	end


--
-- Make sure that the correct compilers are used.
--

	function suite.usesCorrectCompilers()
		gmake.cpp.outputConfigurationSection(prj)
		test.capture [[
# Configurations
# #############################################

ifeq ($(origin CC), default)
  CC = clang
endif
ifeq ($(origin CXX), default)
  CXX = clang++
endif
ifeq ($(origin AR), default)
  AR = ar
endif
]]
	end


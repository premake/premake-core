--
-- gmake2_perfile_flags.lua
-- Tests compiler and linker flags for Makefiles.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake2_perfile_flags")

	local p = premake
	local gmake2 = p.modules.gmake2

	local project = p.project


--
-- Setup
--
	local wks

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = p.workspace.getproject(wks, 1)
		gmake2.cpp.outputPerFileConfigurationSection(prj)
	end


--
-- Test per file settings.
--

	function suite.perfile_buildOptions()
		files { 'a.cpp', 'b.cpp', 'c.cpp' }

		filter { 'files:a.cpp' }
			buildoptions { '-msse', '-msse2', '-mfpmath=sse,387', '-msse3', '-mssse3', '-msse4.1', '-mpclmul' }
		filter { 'files:b.cpp' }
			buildoptions { '-msse', '-msse2', '-mfpmath=sse,387' }
		filter { 'files:c.cpp' }
			buildoptions { '-msse', '-msse2', '-mfpmath=sse,387', '-msse3', '-mssse3', '-msse4.1', '-maes' }

		prepare()
		test.capture [[
# Per File Configurations
# #############################################

PERFILE_FLAGS_0 = $(ALL_CXXFLAGS) -msse -msse2 -mfpmath=sse,387 -msse3 -mssse3 -msse4.1 -mpclmul
PERFILE_FLAGS_1 = $(ALL_CXXFLAGS) -msse -msse2 -mfpmath=sse,387
PERFILE_FLAGS_2 = $(ALL_CXXFLAGS) -msse -msse2 -mfpmath=sse,387 -msse3 -mssse3 -msse4.1 -maes
		]]
	end


	function suite.perfile_mixedbuildOptions()
		files { 'a.c', 'b.cpp', 'c.c' }

		filter { 'files:a.c' }
			buildoptions { '-msse', '-msse2', '-mfpmath=sse,387', '-msse3', '-mssse3', '-msse4.1', '-mpclmul' }
		filter { 'files:b.cpp' }
			buildoptions { '-msse', '-msse2', '-mfpmath=sse,387' }
		filter { 'files:c.c' }
			buildoptions { '-msse', '-msse2', '-mfpmath=sse,387', '-msse3', '-mssse3', '-msse4.1', '-maes' }

		prepare()
		test.capture [[
# Per File Configurations
# #############################################

PERFILE_FLAGS_0 = $(ALL_CFLAGS) -msse -msse2 -mfpmath=sse,387 -msse3 -mssse3 -msse4.1 -mpclmul
PERFILE_FLAGS_1 = $(ALL_CXXFLAGS) -msse -msse2 -mfpmath=sse,387
PERFILE_FLAGS_2 = $(ALL_CFLAGS) -msse -msse2 -mfpmath=sse,387 -msse3 -mssse3 -msse4.1 -maes
		]]
	end

	function suite.perfile_cxxApi()
		files { 'a.cpp', 'b.cpp', 'c.cpp' }

		visibility "Hidden"

		filter { 'files:b.cpp' }
			visibility "Protected"

		prepare()
		test.capture [[
# Per File Configurations
# #############################################

PERFILE_FLAGS_0 = $(ALL_CXXFLAGS) -fvisibility=protected
		]]
	end

	function suite.perfile_compileas()
		files { 'a.c', 'b.cpp' }

		filter { 'files:a.c' }
			compileas "Objective-C"
		filter { 'files:b.cpp' }
			compileas "Objective-C++"

		prepare()
		test.capture [[
# Per File Configurations
# #############################################

PERFILE_FLAGS_0 = $(ALL_CFLAGS) -x objective-c
PERFILE_FLAGS_1 = $(ALL_CXXFLAGS) -x objective-c++
		]]
	end

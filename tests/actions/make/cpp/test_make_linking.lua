--
-- tests/actions/make/cpp/test_make_linking.lua
-- Validate the link step generation for makefiles.
-- Copyright (c) 2010-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_linking")
	local make = premake.make
	local project = premake.project


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		_OS = "linux"
		sln, prj = test.createsolution()
	end

	local function prepare(calls)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = premake.tools.gcc
		premake.callarray(make, calls, cfg, toolset)
	end


--
-- Check link command for a shared C++ library.
--

	function suite.links_onCppSharedLib()
		kind "SharedLib"
		prepare { "ldFlags", "linkCmd" }
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -s -shared
  LINKCMD = $(CXX) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)
		]]
	end


--
-- Check link command for a shared C library.
--

	function suite.links_onCSharedLib()
		language "C"
		kind "SharedLib"
		prepare { "ldFlags", "linkCmd" }
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -s -shared
  LINKCMD = $(CC) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)
		]]
	end


--
-- Check link command for a static library.
--

	function suite.links_onStaticLib()
		kind "StaticLib"
		prepare { "ldFlags", "linkCmd" }
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -s
  LINKCMD = $(AR) -rcs $(TARGET) $(OBJECTS)
		]]
	end


--
-- Check link command for a Mac OS X universal static library.
--

	function suite.links_onMacUniversalStaticLib()
		architecture "universal"
		kind "StaticLib"
		prepare { "ldFlags", "linkCmd" }
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -s
  LINKCMD = libtool -o $(TARGET) $(OBJECTS)
		]]
	end


--
-- Check a linking to a sibling static library.
--

	function suite.links_onSiblingStaticLib()
		links "MyProject2"

		test.createproject(sln)
		kind "StaticLib"
		location "build"

		prepare { "ldFlags", "libs", "ldDeps" }
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -s
  LIBS += build/libMyProject2.a
  LDDEPS += build/libMyProject2.a
		]]
	end


--
-- Check a linking to a sibling shared library.
--

	function suite.links_onSiblingSharedLib()
		links "MyProject2"

		test.createproject(sln)
		kind "SharedLib"
		location "build"

		prepare { "ldFlags", "libs", "ldDeps" }
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -s
  LIBS += build/libMyProject2.so
  LDDEPS += build/libMyProject2.so
		]]
	end

--
-- When referencing an external library via a path, the directory
-- should be added to the library search paths, and the library
-- itself included via an -l flag.
--

 function suite.onExternalLibraryWithPath()
 	location "MyProject"
	links { "libs/SomeLib" }
	prepare { "ldFlags", "libs" }
	test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -s -L../libs
  LIBS += -lSomeLib
	]]
end



--
-- When referencing an external library with a period in the
-- file name make sure it appears correctly in  the LIBS
-- directive. Currently the period and everything after it
-- is stripped
--

 function suite.onExternalLibraryWithPath()
 	location "MyProject"
	links { "libs/SomeLib-1.1" }
	prepare { "libs", }
	test.capture [[
  LIBS += -lSomeLib-1.1
	]]
 end

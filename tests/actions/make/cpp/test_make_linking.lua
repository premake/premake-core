--
-- tests/actions/make/cpp/test_make_linking.lua
-- Validate the link step generation for makefiles.
-- Copyright (c) 2010-2013 Jason Perkins and the Premake project
--

	T.make_linking = { }
	local suite = T.make_linking
	local cpp = premake.make.cpp
	local project = premake5.project


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		_OS = "linux"
		sln, prj = test.createsolution()
	end

	local function prepare()
		local cfg = project.getconfig(prj, "Debug")
		cpp.linkconfig(cfg, premake.tools.gcc)
	end


--
-- Check link command for a shared C++ library.
--

	function suite.links_onCppSharedLib()
		kind "SharedLib"
		prepare()
		test.capture [[
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(LIBS) $(ALL_LDFLAGS)
		]]
	end


--
-- Check link command for a shared C library.
--

	function suite.links_onCppSharedLib()
		language "C"
		kind "SharedLib"
		prepare()
		test.capture [[
  ALL_LDFLAGS  += $(LDFLAGS) -s -shared
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = $(CC) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(LIBS) $(ALL_LDFLAGS)
		]]
	end


--
-- Check link command for a static library.
--

	function suite.links_onStaticLib()
		kind "StaticLib"
		prepare()
		test.capture [[
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
		]]
	end


--
-- Check link command for a Mac OS X universal static library.
--

	function suite.links_onStaticLib()
		architecture "universal"
		kind "StaticLib"
		prepare()
		test.capture [[
  ALL_LDFLAGS  += $(LDFLAGS) -s
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = libtool -o $(TARGET) $(OBJECTS)
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

		prepare()
		test.capture [[
  ALL_LDFLAGS  += $(LDFLAGS) -s
  LIBS      += build/libMyProject2.a
  LDDEPS    += build/libMyProject2.a
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

		prepare()
		test.capture [[
  ALL_LDFLAGS  += $(LDFLAGS) -s
  LIBS      += build/libMyProject2.so
  LDDEPS    += build/libMyProject2.so
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
	prepare()
	test.capture [[
  ALL_LDFLAGS  += $(LDFLAGS) -L../libs -s
  LIBS      += -lSomeLib
  LDDEPS    +=
	]]
 end

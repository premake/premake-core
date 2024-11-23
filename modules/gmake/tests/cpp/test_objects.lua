--
-- tests/actions/make/cpp/test_objects.lua
-- Validate the list of objects for a makefile.
-- Copyright (c) 2009-2015 Jess Perkins and the Premake project
--

	local suite = test.declare("make_cpp_objects")

	local p = premake


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		p.make.cppObjects(prj)
	end


--
-- If a file is listed at the project level, it should get listed in
-- the project level objects list.
--

	function suite.listFileInProjectObjects()
		files { "src/hello.cpp" }
		prepare()
		test.capture [[
OBJECTS := \
	$(OBJDIR)/hello.o \

		]]
	end


--
-- Only buildable files should be listed.
--

	function suite.onlyListBuildableFiles()
		files { "include/gl.h", "src/hello.cpp" }
		prepare()
		test.capture [[
OBJECTS := \
	$(OBJDIR)/hello.o \

		]]
	end


--
-- A file should only be listed in the configurations to which it belongs.
--

	function suite.configFilesAreConditioned()
		filter "Debug"
		files { "src/hello_debug.cpp" }
		filter "Release"
		files { "src/hello_release.cpp" }
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

CUSTOMFILES := \

ifeq ($(config),debug)
  OBJECTS += \
	$(OBJDIR)/hello_debug.o \

endif

ifeq ($(config),release)
  OBJECTS += \
	$(OBJDIR)/hello_release.o \

endif

		]]
	end


--
-- Two files with the same base name should have different object files.
--

	function suite.uniqueObjNames_onBaseNameCollision()
		files { "src/hello.cpp", "src/greetings/hello.cpp" }
		prepare()
		test.capture [[
OBJECTS := \
	$(OBJDIR)/hello.o \
	$(OBJDIR)/hello1.o \

		]]
	end


--
-- If a custom rule builds to an object file, include it in the
-- link automatically to match the behavior of Visual Studio
--

	function suite.linkBuildOutputs_onNotSpecified()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling %{file.name}"
			buildcommands {
				'cxc -c "%{file.path}" -o "%{cfg.objdir}/%{file.basename}.xo"',
				'c2o -c "%{cfg.objdir}/%{file.basename}.xo" -o "%{cfg.objdir}/%{file.basename}.obj"'
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.obj" }
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

CUSTOMFILES := \

ifeq ($(config),debug)
  OBJECTS += \
	obj/Debug/hello.obj \

endif

		]]
	end


--
-- Also include it in the link step if we explicitly specified so with
-- linkbuildoutputs.
--

	function suite.linkBuildOutputs_onOn()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling %{file.name}"
			buildcommands {
				'cxc -c "%{file.path}" -o "%{cfg.objdir}/%{file.basename}.xo"',
				'c2o -c "%{cfg.objdir}/%{file.basename}.xo" -o "%{cfg.objdir}/%{file.basename}.obj"'
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.obj" }
			linkbuildoutputs "On"
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

CUSTOMFILES := \

ifeq ($(config),debug)
  OBJECTS += \
	obj/Debug/hello.obj \

endif

		]]
	end


--
-- If linkbuildoutputs says that we shouldn't include it in the link however,
-- don't do it.
--

	function suite.linkBuildOutputs_onOff()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling %{file.name}"
			buildcommands {
				'cxc -c "%{file.path}" -o "%{cfg.objdir}/%{file.basename}.xo"',
				'c2o -c "%{cfg.objdir}/%{file.basename}.xo" -o "%{cfg.objdir}/%{file.basename}.obj"'
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.obj" }
			linkbuildoutputs "Off"
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

CUSTOMFILES := \

ifeq ($(config),debug)
  CUSTOMFILES += \
	obj/Debug/hello.obj \

endif

		]]
	end


--
-- If a file is excluded from a configuration, it should not be listed.
--

	function suite.excludedFromBuild_onExcludedFile()
		files { "hello.cpp" }
		filter "Debug"
		removefiles { "hello.cpp" }
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

CUSTOMFILES := \

ifeq ($(config),release)
  OBJECTS += \
	$(OBJDIR)/hello.o \

endif

		]]
	end

	function suite.excludedFromBuild_onExcludeFlag()
		files { "hello.cpp" }
		filter { "Debug", "files:hello.cpp" }
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

CUSTOMFILES := \

ifeq ($(config),release)
  OBJECTS += \
	$(OBJDIR)/hello.o \

endif

		]]
	end

	function suite.excludedFromBuild_onBuildactionNone()
		files { "hello.cpp" }
		filter { "Debug", "files:hello.cpp" }
			buildaction "None"
		filter {}
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

CUSTOMFILES := \

ifeq ($(config),release)
  OBJECTS += \
	$(OBJDIR)/hello.o \

endif

		]]
	end

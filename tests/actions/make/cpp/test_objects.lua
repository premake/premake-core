--
-- tests/actions/make/cpp/test_objects.lua
-- Validate the list of objects for a makefile.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.make_cpp_objects = { }
	local suite = T.make_cpp_objects
	local cpp = premake.make.cpp
	local project = premake5.project


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln = test.createsolution()
	end
	
	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cpp.objects(prj)
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
		configuration "Debug"
		files { "src/hello_debug.cpp" }
		configuration "Release"
		files { "src/hello_release.cpp" }
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

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
-- Check handling of Windows resource files.
--

	function suite.compilesWindowsResourceFiles()
		files { "src/hello.rc", "src/greetings/hello.rc" }
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \
	$(OBJDIR)/hello.res \
	$(OBJDIR)/hello1.res \

		]]
	end




--
-- If a custom rule builds to an object file, include it in the
-- link automatically to match the behavior of Visual Studio
--

	function suite.customBuildRule()
		files { "hello.x" }
		configuration "**.x"
			buildrule {
				description = "Compiling %{file.name}",
				commands = { 
					'cxc -c "%{file.path}" -o "%{cfg.objdir}/%{file.basename}.xo"', 
					'c2o -c "%{cfg.objdir}/%{file.basename}.xo" -o "%{cfg.objdir}/%{file.basename}.obj"'
				},
				outputs = { "%{cfg.objdir}/%{file.basename}.obj" }
			}
		prepare()
		test.capture [[
OBJECTS := \

RESOURCES := \

ifeq ($(config),debug)
  OBJECTS += \
	obj/Debug/hello.obj \

endif

		]]
	end

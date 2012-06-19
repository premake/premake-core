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
		files { "src/hello.cpp" }
		prepare()
		test.capture [[
OBJECTS := \

ifeq ($(config),debug)
  OBJECTS += \
	$(OBJDIR)/hello.o \

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


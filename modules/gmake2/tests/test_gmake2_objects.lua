--
-- test_gmake2_objects.lua
-- Validate the list of objects for a makefile.
-- (c) 2016-2017 Jason Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake2_objects")

	local p = premake
	local gmake2 = p.modules.gmake2


--
-- Setup
--

	local wks, prj

	function suite.setup()
		gmake2.cpp.initialize()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		gmake2.cpp.createRuleTable(prj)
		gmake2.cpp.createFileTable(prj)
		gmake2.cpp.outputFilesSection(prj)
	end


--
-- If a file is listed at the project level, it should get listed in
-- the project level objects list.
--

	function suite.listFileInProjectObjects()
		files { "src/hello.cpp" }
		prepare()
		test.capture [[
# File sets
# #############################################

OBJECTS :=

OBJECTS += $(OBJDIR)/hello.o

		]]
	end


--
-- Only buildable files should be listed.
--

	function suite.onlyListBuildableFiles()
		files { "include/gl.h", "src/hello.cpp" }
		prepare()
		test.capture [[
# File sets
# #############################################

OBJECTS :=

OBJECTS += $(OBJDIR)/hello.o

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
# File sets
# #############################################

OBJECTS :=

ifeq ($(config),debug)
OBJECTS += $(OBJDIR)/hello_debug.o

else ifeq ($(config),release)
OBJECTS += $(OBJDIR)/hello_release.o

else
  $(error "invalid configuration $(config)")
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
# File sets
# #############################################

OBJECTS :=

OBJECTS += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello1.o

		]]
	end

	function suite.uniqueObjNames_onBaseNameCollision2()
		files { "a/hello.cpp", "b/hello.cpp", "c/hello1.cpp" }
		prepare()
		test.capture [[
# File sets
# #############################################

OBJECTS :=

OBJECTS += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello1.o
OBJECTS += $(OBJDIR)/hello11.o

		]]
	end

	function suite.uniqueObjectNames_onBaseNameCollision_Release()
		files { "a/hello.cpp", "b/hello.cpp", "c/hello1.cpp", "d/hello11.cpp" }
		filter "configurations:Debug"
			excludes {"b/hello.cpp"}
		filter "configurations:Release"
			excludes {"d/hello11.cpp"}

		prepare()
		test.capture [[
# File sets
# #############################################

OBJECTS :=

OBJECTS += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello11.o

ifeq ($(config),debug)
OBJECTS += $(OBJDIR)/hello111.o

else ifeq ($(config),release)
OBJECTS += $(OBJDIR)/hello1.o

else
  $(error "invalid configuration $(config)")
endif

		]]
	end


--
-- If there's a custom rule for a non-C++ file extension, make sure that those
-- files are included in the build.
--

	function suite.customBuildCommand_onCustomFileType()
		files { "hello.lua" }
		filter "files:**.lua"
			buildmessage "Compiling %{file.name}"
			buildcommands {
				'luac "%{file.path}" -o "%{cfg.objdir}/%{file.basename}.luac"',
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.luac" }
		prepare()
		test.capture [[
# File sets
# #############################################

CUSTOM :=

ifeq ($(config),debug)
CUSTOM += obj/Debug/hello.luac

else ifeq ($(config),release)
CUSTOM += obj/Release/hello.luac

else
  $(error "invalid configuration $(config)")
endif
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
# File sets
# #############################################

OBJECTS :=

ifeq ($(config),debug)
OBJECTS += obj/Debug/hello.obj

else ifeq ($(config),release)
OBJECTS += obj/Release/hello.obj

else
  $(error "invalid configuration $(config)")
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
# File sets
# #############################################

OBJECTS :=

ifeq ($(config),debug)
OBJECTS += obj/Debug/hello.obj

else ifeq ($(config),release)
OBJECTS += obj/Release/hello.obj

else
  $(error "invalid configuration $(config)")
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
# File sets
# #############################################

CUSTOM :=

ifeq ($(config),debug)
CUSTOM += obj/Debug/hello.obj

else ifeq ($(config),release)
CUSTOM += obj/Release/hello.obj

else
  $(error "invalid configuration $(config)")
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
# File sets
# #############################################

OBJECTS :=

ifeq ($(config),release)
OBJECTS += $(OBJDIR)/hello.o

else
  $(error "invalid configuration $(config)")
endif

		]]
	end

	function suite.excludedFromBuild_onExcludeFlag()
		files { "hello.cpp" }
		filter { "Debug", "files:hello.cpp" }
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
# File sets
# #############################################

OBJECTS :=

ifeq ($(config),release)
OBJECTS += $(OBJDIR)/hello.o

else
  $(error "invalid configuration $(config)")
endif

		]]
	end

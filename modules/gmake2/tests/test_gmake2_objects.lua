--
-- test_gmake2_objects.lua
-- Validate the list of objects for a makefile.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
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

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello.o

		]]
	end

	function suite.listResoucesInProjectObjects()
		files { "src/hello.rc" }
		prepare()
		test.capture [[
# File sets
# #############################################

GENERATED :=
RESOURCES :=

GENERATED += $(OBJDIR)/hello.res
RESOURCES += $(OBJDIR)/hello.res

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

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/hello.o
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

GENERATED :=
OBJECTS :=

ifeq ($(config),debug)
GENERATED += $(OBJDIR)/hello_debug.o
OBJECTS += $(OBJDIR)/hello_debug.o

else ifeq ($(config),release)
GENERATED += $(OBJDIR)/hello_release.o
OBJECTS += $(OBJDIR)/hello_release.o

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

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/hello.o
GENERATED += $(OBJDIR)/hello1.o
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

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/hello.o
GENERATED += $(OBJDIR)/hello1.o
GENERATED += $(OBJDIR)/hello11.o
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

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/hello.o
GENERATED += $(OBJDIR)/hello11.o
OBJECTS += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello11.o

ifeq ($(config),debug)
GENERATED += $(OBJDIR)/hello111.o
OBJECTS += $(OBJDIR)/hello111.o

else ifeq ($(config),release)
GENERATED += $(OBJDIR)/hello1.o
OBJECTS += $(OBJDIR)/hello1.o

endif

		]]
	end

--
-- Test that changes in case are treated as if multiple files of the same name are being built
--

	function suite.uniqueObjNames_ignoreCase1()
		files { "a/hello.cpp", "b/Hello.cpp" }
		prepare()
		test.capture [[
# File sets
# #############################################

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/Hello1.o
GENERATED += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/Hello1.o
OBJECTS += $(OBJDIR)/hello.o

		]]
	end

	function suite.uniqueObjNames_ignoreCase2()
		files { "a/hello.cpp", "b/hello.cpp", "c/Hello1.cpp" }
		prepare()
		test.capture [[
# File sets
# #############################################

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/Hello11.o
GENERATED += $(OBJDIR)/hello.o
GENERATED += $(OBJDIR)/hello1.o
OBJECTS += $(OBJDIR)/Hello11.o
OBJECTS += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello1.o

		]]
	end

	function suite.uniqueObjectNames_ignoreCase_Release()
		files { "a/hello.cpp", "b/hello.cpp", "c/Hello1.cpp", "d/Hello11.cpp" }
		filter "configurations:Debug"
			excludes {"b/hello.cpp"}
		filter "configurations:Release"
			excludes {"d/Hello11.cpp"}

		prepare()
		test.capture [[
# File sets
# #############################################

GENERATED :=
OBJECTS :=

GENERATED += $(OBJDIR)/Hello11.o
GENERATED += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/Hello11.o
OBJECTS += $(OBJDIR)/hello.o

ifeq ($(config),debug)
GENERATED += $(OBJDIR)/Hello111.o
OBJECTS += $(OBJDIR)/Hello111.o

else ifeq ($(config),release)
GENERATED += $(OBJDIR)/hello1.o
OBJECTS += $(OBJDIR)/hello1.o

endif

		]]
	end


--
-- If there's a custom rule which generate C++ sources build outputs should be placed
-- in separate list so they can be cleaned up properly.
--

	function suite.customBuildCommand_generatedCpp()
		files { "interface.pkg","source.cpp" }
		filter "files:**.pkg"
			buildmessage "Binding pkg: %{file.name}"
			buildcommands './tolua -o %{file.basename}.cpp -H %{file.basename}.h -n %{file.basename}}  %{file.abspath}'
			buildoutputs { '%{file.basename}.cpp','%{file.basename}.h' }
		prepare()
		test.capture [[
# File sets
# #############################################

CUSTOM :=
GENERATED :=
OBJECTS :=
SOURCES :=

CUSTOM += interface.h
GENERATED += $(OBJDIR)/interface.o
GENERATED += $(OBJDIR)/source.o
GENERATED += interface.cpp
GENERATED += interface.h
OBJECTS += $(OBJDIR)/interface.o
OBJECTS += $(OBJDIR)/source.o
SOURCES += interface.cpp
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
GENERATED :=

ifeq ($(config),debug)
CUSTOM += obj/Debug/hello.luac
GENERATED += obj/Debug/hello.luac

else ifeq ($(config),release)
CUSTOM += obj/Release/hello.luac
GENERATED += obj/Release/hello.luac

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

GENERATED :=
OBJECTS :=

ifeq ($(config),debug)
GENERATED += obj/Debug/hello.obj
OBJECTS += obj/Debug/hello.obj

else ifeq ($(config),release)
GENERATED += obj/Release/hello.obj
OBJECTS += obj/Release/hello.obj

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

GENERATED :=
OBJECTS :=

ifeq ($(config),debug)
GENERATED += obj/Debug/hello.obj
OBJECTS += obj/Debug/hello.obj

else ifeq ($(config),release)
GENERATED += obj/Release/hello.obj
OBJECTS += obj/Release/hello.obj

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
GENERATED :=

ifeq ($(config),debug)
CUSTOM += obj/Debug/hello.obj
GENERATED += obj/Debug/hello.obj

else ifeq ($(config),release)
CUSTOM += obj/Release/hello.obj
GENERATED += obj/Release/hello.obj

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

GENERATED :=
OBJECTS :=

ifeq ($(config),release)
GENERATED += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello.o

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

GENERATED :=
OBJECTS :=

ifeq ($(config),release)
GENERATED += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello.o

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
# File sets
# #############################################

GENERATED :=
OBJECTS :=

ifeq ($(config),release)
GENERATED += $(OBJDIR)/hello.o
OBJECTS += $(OBJDIR)/hello.o

endif

		]]
	end

	function suite.objectsOnBuildactionCopy()
		files { "hello.dll" }
		filter { "Debug", "files:hello.dll" }
			buildaction "Copy"
		filter {}
		prepare()
		test.capture [[
# File sets
# #############################################

CUSTOM :=
GENERATED :=

ifeq ($(config),debug)
CUSTOM += $(TARGETDIR)/hello.dll
GENERATED += $(TARGETDIR)/hello.dll

endif

		]]
	end


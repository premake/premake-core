--
-- test_gmake2_file_rules.lua
-- Validate the makefile source building rules.
-- (c) 2016-2017 Jason Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake2_file_rules")

	local p = premake
	local gmake2 = p.modules.gmake2

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.escaper(gmake2.esc)
		gmake2.cpp.initialize()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = p.workspace.getproject(wks, 1)
		p.oven.bake()

		gmake2.cpp.createRuleTable(prj)
		gmake2.cpp.createFileTable(prj)
		gmake2.cpp.outputFileRuleSection(prj)
	end


--
-- Two files with the same base name should have different object files.
--

	function suite.uniqueObjNames_onBaseNameCollision()
		files { "src/hello.cpp", "src/greetings/hello.cpp" }
		prepare()
		test.capture [[
# File Rules
# #############################################

$(OBJDIR)/hello.o: src/greetings/hello.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"
$(OBJDIR)/hello1.o: src/hello.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"

		]]
	end


--
-- C files in C++ projects should been compiled as c
--

	function suite.cFilesGetsCompiledWithCCWhileInCppProject()
		files { "src/hello.c", "src/test.cpp" }
		prepare()
		test.capture [[
# File Rules
# #############################################

$(OBJDIR)/hello.o: src/hello.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(ALL_CFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"
$(OBJDIR)/test.o: src/test.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"

		]]
	end


--
-- If a custom build rule is supplied, it should be used.
--

	function suite.customBuildRule()
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
# File Rules
# #############################################

ifeq ($(config),debug)
obj/Debug/hello.obj: hello.x
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Debug/hello.xo"
	$(SILENT) c2o -c "obj/Debug/hello.xo" -o "obj/Debug/hello.obj"
endif

ifeq ($(config),release)
obj/Release/hello.obj: hello.x
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Release/hello.xo"
	$(SILENT) c2o -c "obj/Release/hello.xo" -o "obj/Release/hello.obj"
endif
		]]
	end

	function suite.customBuildRuleWithAdditionalInputs()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling %{file.name}"
			buildcommands {
				'cxc -c "%{file.path}" -o "%{cfg.objdir}/%{file.basename}.xo"',
				'c2o -c "%{cfg.objdir}/%{file.basename}.xo" -o "%{cfg.objdir}/%{file.basename}.obj"'
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.obj" }
			buildinputs { "%{file.path}.inc", "%{file.path}.inc2" }
		prepare()
		test.capture [[
# File Rules
# #############################################

ifeq ($(config),debug)
obj/Debug/hello.obj: hello.x hello.x.inc hello.x.inc2
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Debug/hello.xo"
	$(SILENT) c2o -c "obj/Debug/hello.xo" -o "obj/Debug/hello.obj"
endif

ifeq ($(config),release)
obj/Release/hello.obj: hello.x hello.x.inc hello.x.inc2
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Release/hello.xo"
	$(SILENT) c2o -c "obj/Release/hello.xo" -o "obj/Release/hello.obj"
endif
		]]
	end

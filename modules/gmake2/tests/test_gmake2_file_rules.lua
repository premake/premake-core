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

		rule "TestRule"
		display "Test Rule"
		fileextension ".rule"

		propertydefinition {
			name = "TestProperty",
			kind = "boolean",
			value = false,
			switch = "-p"
		}

		propertydefinition {
			name = "TestProperty2",
			kind = "boolean",
			value = false,
			switch = "-p2"
		}
	
		propertydefinition {
			name = "TestListProperty",
			kind = "list"
		}
	
		propertydefinition {
			name = "TestListPropertySeparator",
			kind = "list",
			separator = ","
		}

		buildmessage 'Rule-ing %{file.name}'
		buildcommands 'dorule %{TestProperty} %{TestProperty2} %{TestListProperty} %{TestListPropertySeparator} "%{file.path}"'
		buildoutputs { "%{file.basename}.obj" }

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
-- C files in C++ projects can be compiled as C++ with compileas
--

	function suite.cFilesGetsCompiledWithCXXWithCompileas()
		files { "src/hello.c", "src/test.c" }
		filter { "files:src/hello.c" }
			compileas "C++"
		prepare()
		test.capture [[
# File Rules
# #############################################

$(OBJDIR)/hello.o: src/hello.c
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"
$(OBJDIR)/test.o: src/test.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(ALL_CFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"
		]]
	end

--
-- C files in C++ projects can be compiled as C++ with 'compileas' on a configuration basis
--

	function suite.cFilesGetsCompiledWithCXXWithCompileasDebugOnly()
		files { "src/hello.c", "src/test.c" }
		filter { "configurations:Debug", "files:src/hello.c" }
			compileas "C++"
		prepare()
		test.capture [[
# File Rules
# #############################################

$(OBJDIR)/test.o: src/test.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(ALL_CFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"

ifeq ($(config),debug)
$(OBJDIR)/hello.o: src/hello.c
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"

else ifeq ($(config),release)
$(OBJDIR)/hello.o: src/hello.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(ALL_CFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"

else
  $(error "invalid configuration $(config)")
endif
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

else ifeq ($(config),release)
obj/Release/hello.obj: hello.x
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Release/hello.xo"
	$(SILENT) c2o -c "obj/Release/hello.xo" -o "obj/Release/hello.obj"

else
  $(error "invalid configuration $(config)")
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

else ifeq ($(config),release)
obj/Release/hello.obj: hello.x hello.x.inc hello.x.inc2
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Release/hello.xo"
	$(SILENT) c2o -c "obj/Release/hello.xo" -o "obj/Release/hello.obj"

else
  $(error "invalid configuration $(config)")
endif
		]]
	end

	function suite.customBuildRuleWithAdditionalOutputs()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling %{file.name}"
			buildcommands {
				'cxc -c "%{file.path}" -o "%{cfg.objdir}/%{file.basename}.xo"',
				'c2o -c "%{cfg.objdir}/%{file.basename}.xo" -o "%{cfg.objdir}/%{file.basename}.obj"'
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.obj", "%{cfg.objdir}/%{file.basename}.other", "%{cfg.objdir}/%{file.basename}.another" }
		prepare()
		test.capture [[
# File Rules
# #############################################

ifeq ($(config),debug)
obj/Debug/hello.obj: hello.x
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Debug/hello.xo"
	$(SILENT) c2o -c "obj/Debug/hello.xo" -o "obj/Debug/hello.obj"
obj/Debug/hello.other obj/Debug/hello.another: obj/Debug/hello.obj

else ifeq ($(config),release)
obj/Release/hello.obj: hello.x
	@echo Compiling hello.x
	$(SILENT) cxc -c "hello.x" -o "obj/Release/hello.xo"
	$(SILENT) c2o -c "obj/Release/hello.xo" -o "obj/Release/hello.obj"
obj/Release/hello.other obj/Release/hello.another: obj/Release/hello.obj

else
  $(error "invalid configuration $(config)")
endif
		]]
	end

	function suite.customRuleWithProps()

		rules { "TestRule" }

		files { "test.rule", "test2.rule" }

		testRuleVars {
			TestProperty = true
		}

		filter "files:test2.rule"
			testRuleVars {
				TestProperty2 = true
			}

		prepare()
		test.capture [[
# File Rules
# #############################################

test.obj: test.rule
	@echo Rule-ing test.rule
	$(SILENT) dorule -p    "test.rule"
test2.obj: test2.rule
	@echo Rule-ing test2.rule
	$(SILENT) dorule -p -p2   "test2.rule"
		]]
	end

	function suite.propertydefinitionSeparator()

		rules { "TestRule" }

		files { "test.rule", "test2.rule" }

		filter "files:test.rule"
			testRuleVars {
				TestListProperty = { "testValue1", "testValue2" }
			}

		filter "files:test2.rule"
			testRuleVars {
				TestListPropertySeparator = { "testValue1", "testValue2" }
			}

		prepare()
		test.capture [[
# File Rules
# #############################################

test.obj: test.rule
	@echo Rule-ing test.rule
	$(SILENT) dorule   testValue1\ testValue2  "test.rule"
test2.obj: test2.rule
	@echo Rule-ing test2.rule
	$(SILENT) dorule    testValue1,testValue2 "test2.rule"
		]]
	end


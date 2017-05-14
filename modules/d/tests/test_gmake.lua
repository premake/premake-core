---
-- d/tests/test_gmake.lua
-- Automated test suite for gmake project generation.
-- Copyright (c) 2011-2015 Manu Evans and the Premake project
---

	local suite = test.declare("d_make")
	local p = premake
	local m = p.modules.d

	local make = p.make
	local project = p.project


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		p.escaper(make.esc)
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = p.workspace.getproject(wks, 1)
	end

	local function prepare_cfg(calls)
		prj = p.workspace.getproject(wks, 1)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = p.tools.dmd
		p.callArray(calls, cfg, toolset)
	end



--
-- Check project generation
--

	function suite.make_targetRules()
		prepare()
		m.make.targetRules(prj)
		test.capture [[
$(TARGET): $(SOURCEFILES) $(LDDEPS)
	@echo Building MyProject
	$(SILENT) $(BUILDCMD)
	$(POSTBUILDCMDS)

		]]
	end

	function suite.make_targetRules_separateCompilation()
		flags { "SeparateCompilation" }
		prepare()
		m.make.targetRules(prj)
		test.capture [[
$(TARGET): $(OBJECTS) $(LDDEPS)
	@echo Linking MyProject
	$(SILENT) $(LINKCMD)
	$(POSTBUILDCMDS)

		]]
	end

	function suite.make_targetRules_mixedCompilation()
		configuration { "Release" }
			flags { "SeparateCompilation" }
		prepare()
		m.make.targetRules(prj)
		test.capture [[
ifeq ($(config),debug)
$(TARGET): $(SOURCEFILES) $(LDDEPS)
	@echo Building MyProject
	$(SILENT) $(BUILDCMD)
	$(POSTBUILDCMDS)
endif
ifeq ($(config),release)
$(TARGET): $(OBJECTS) $(LDDEPS)
	@echo Linking MyProject
	$(SILENT) $(LINKCMD)
	$(POSTBUILDCMDS)
endif

		]]
	end


	function suite.make_fileRules()
		files { "blah.d" }
		prepare()
		m.make.dFileRules(prj)
		test.capture [[

		]]
	end

	function suite.make_fileRules_separateCompilation()
		files { "blah.d" }
		flags { "SeparateCompilation" }
		prepare()
		m.make.dFileRules(prj)
		test.capture [[
$(OBJDIR)/blah.o: blah.d
	@echo $(notdir $<)
	$(SILENT) $(DC) $(ALL_DFLAGS) $(OUTPUTFLAG) -c $<
		]]
	end

	function suite.make_fileRules_mixedCompilation()
		files { "blah.d" }
		configuration { "Release" }
			flags { "SeparateCompilation" }
		prepare()
		m.make.dFileRules(prj)
		test.capture [[
$(OBJDIR)/blah.o: blah.d
	@echo $(notdir $<)
	$(SILENT) $(DC) $(ALL_DFLAGS) $(OUTPUTFLAG) -c $<
		]]
	end


	function suite.make_objects()
		files { "blah.d" }
		prepare()
		m.make.objects(prj)
		test.capture [[
SOURCEFILES := \
	blah.d \

		]]
	end

	function suite.make_objects_separateCompilation()
		files { "blah.d" }
		flags { "SeparateCompilation" }
		prepare()
		m.make.objects(prj)
		test.capture [[
OBJECTS := \
	$(OBJDIR)/blah.o \

		]]
	end

	function suite.make_objects_mixedCompilation()
		files { "blah.d" }
		configuration { "Release" }
			flags { "SeparateCompilation" }
			files { "blah2.d" }
		prepare()
		m.make.objects(prj)
		test.capture [[
SOURCEFILES := \
	blah.d \

OBJECTS := \
	$(OBJDIR)/blah.o \

ifeq ($(config),release)
  SOURCEFILES += \
	blah2.d \

  OBJECTS += \
	$(OBJDIR)/blah2.o \

endif

		]]
	end


--
-- Check configuration generation
--

	function suite.make_allRules()
		prepare_cfg({ m.make.allRules })
		test.capture [[
all: $(TARGETDIR) prebuild prelink $(TARGET)
	@:
		]]
	end

	function suite.make_allRules_separateCompilation()
		flags { "SeparateCompilation" }
		prepare_cfg({ m.make.allRules })
		test.capture [[
all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)
	@:
		]]
	end

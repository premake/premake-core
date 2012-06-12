--
-- tests/actions/make/cpp/test_make_pch.lua
-- Validate the setup for precompiled headers in makefiles.
-- Copyright (c) 2010-2012 Jason Perkins and the Premake project
--

	T.make_pch = { }
	local suite = T.make_pch
	local cpp = premake.make.cpp
	local project = premake5.project
	
	

--
-- Setup and teardown
--

	local sln, prj, cfg
	function suite.setup()
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		cfg = project.getconfig(prj, "Debug")
	end


--
-- If no header has been set, nothing should be output.
--
	
	function suite.noConfig_onNoHeaderSet()
		prepare()
		cpp.pchconfig(cfg)
		test.isemptycapture()
	end


--
-- If a header is set, but the NoPCH flag is also set, then
-- nothing should be output.
--

	function suite.noConfig_onHeaderAndNoPCHFlag()
		pchheader "include/myproject.h"
		flags "NoPCH"
		prepare()
		cpp.pchconfig(cfg)
		test.isemptycapture()
	end


--
-- If a header is specified and the NoPCH flag is not set, then
-- the header can be used.
--

	function suite.config_onPchEnabled()
		pchheader "include/myproject.h"
		prepare()
		cpp.pchconfig(cfg)
		test.capture [[
  PCH        = include/myproject.h
  GCH        = $(OBJDIR)/myproject.h.gch
  CPPFLAGS  += -I$(OBJDIR) -include $(OBJDIR)/myproject.h
		]]
	end


--
-- The PCH can be specified relative the an includes search path.
--

	function suite.pch_searchesIncludeDirs()
		pchheader "premake.h"
		includedirs { "../src/host" }
		prepare()
		cpp.pchconfig(cfg)
		test.capture [[
  PCH        = ../src/host/premake.h
  GCH        = $(OBJDIR)/premake.h.gch
  CPPFLAGS  += -I$(OBJDIR) -include $(OBJDIR)/premake.h
		]]
	end


-- 
-- Verify the format of the PCH rules block for a C++ file.
--

	function suite.buildRules_onCpp()
		pchheader "include/myproject.h"
		prepare()
		cpp.pchrules(cfg.project)
		test.capture [[
ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
ifeq (posix,$(SHELLTYPE))
	-$(SILENT) cp $< $(OBJDIR)
else
	$(SILENT) xcopy /D /Y /Q "$(subst /,\,$<)" "$(subst /,\,$(OBJDIR))" 1>nul
endif
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -MF $(@:%.o=%.d) -c "$<"
endif
		]]
	end


-- 
-- Verify the format of the PCH rules block for a C file.
--

	function suite.buildRules_onC()
		language "C"
		pchheader "include/myproject.h"
		prepare()
		cpp.pchrules(cfg.project)
		test.capture [[
ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
ifeq (posix,$(SHELLTYPE))
	-$(SILENT) cp $< $(OBJDIR)
else
	$(SILENT) xcopy /D /Y /Q "$(subst /,\,$<)" "$(subst /,\,$(OBJDIR))" 1>nul
endif
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -MF $(@:%.o=%.d) -c "$<"
endif
		]]
	end

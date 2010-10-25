--
-- tests/actions/make/test_make_pch.lua
-- Validate the setup for precompiled headers in makefiles.
-- Copyright (c) 2010 Jason Perkins and the Premake project
--

	T.make_pch = { }
	local suite = T.make_pch
	local _ = premake.make.cpp
	

--
-- Setup and teardown
--

	local sln, prj, cfg
	function suite.setup()
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		io.capture()
		premake.buildconfigs()
		cfg = premake.getconfig(prj, "Debug")
	end
	

--
-- Configuration block tests
--
	
	function suite.NoConfig_OnNoHeaderSet()
		prepare()
		_.pchconfig(cfg)
		test.capture [[]]
	end

	
	function suite.NoConfig_OnHeaderAndNoPCHFlag()
		pchheader "include/myproject.h"
		flags { NoPCH }
		prepare()
		_.pchconfig(cfg)
		test.capture [[]]
	end


	function suite.ConfigBlock_OnPchEnabled()
		pchheader "include/myproject.h"
		prepare()
		_.pchconfig(cfg)
		test.capture [[
  PCH        = include/myproject.h
  GCH        = $(OBJDIR)/myproject.h.gch
  CPPFLAGS  += -I$(OBJDIR) -include $(OBJDIR)/myproject.h
		]]
	end


-- 
-- Build rule tests
--

	function suite.BuildRules_OnCpp()
		pchheader "include/myproject.h"
		prepare()
		_.pchrules(prj)
		test.capture [[
ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
	-$(SILENT) cp $< $(OBJDIR)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
endif
		]]
	end

	function suite.BuildRules_OnC()
		language "C"
		pchheader "include/myproject.h"
		prepare()
		_.pchrules(prj)
		test.capture [[
ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
	-$(SILENT) cp $< $(OBJDIR)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
endif
		]]
	end
	

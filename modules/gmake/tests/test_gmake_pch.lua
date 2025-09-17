--
-- test_gmake_pch.lua
-- Validate the setup for precompiled headers in makefiles.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local p = premake
	local suite = test.declare("gmake_pch")

	local p = premake
	local gmake = p.modules.gmake

	local project = p.project



--
-- Setup and teardown
--

	local wks, prj
	function suite.setup()
		gmake.cpp.initialize()
		wks, prj = test.createWorkspace()
	end

	local function prepareVars()
		local cfg = test.getconfig(prj, "Debug")
		gmake.cpp.pch(cfg)
	end

	local function prepareRules()
		local cfg = test.getconfig(prj, "Debug")
		gmake.cpp.pchRules(cfg.project)
	end

	local function prepareFlags()
		local project = test.getproject(wks, 1)
		gmake.cpp.createRuleTable(project)
		gmake.cpp.createFileTable(project)
		gmake.cpp.outputFileRuleSection(project)
	end

--
-- If no header has been set, nothing should be output.
--

	function suite.noConfig_onNoHeaderSet()
		prepareVars()
		test.isemptycapture()
	end


--
-- If a header is set, but the NoPCH flag is also set, then
-- nothing should be output.
--

	function suite.noConfig_onHeaderAndNoPCHFlag()
		pchheader "include/myproject.h"
		flags "NoPCH"

		files { 'a.cpp', 'b.cpp' }

		prepareFlags()
		test.capture [[
# File Rules
# #############################################

$(OBJDIR)/a.o: a.cpp
	@echo "$(notdir $<)"
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -c "$<"
$(OBJDIR)/b.o: b.cpp
	@echo "$(notdir $<)"
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -c "$<"
]]
	end


--
-- If a header is specified and the NoPCH flag is not set, then
-- the header can be used.
--

	function suite.config_onPchEnabled()
		pchheader "include/myproject.h"
		prepareVars()
		test.capture [[
PCH = include/myproject.h
PCH_PLACEHOLDER = $(OBJDIR)/$(notdir $(PCH))
GCH = $(PCH_PLACEHOLDER).gch
		]]
	end


--
-- The PCH can be specified relative to the includes search path.
--

	function suite.searchesIncludeDirs()
		pchheader "premake.h"
		includedirs { "src/host" }
		prepareVars()
		test.capture [[
PCH = src/host/premake.h
		]]
	end

--
-- The PCH can be specified relative to the includes search path.
-- Due to the location being different from _MAIN_SCRIPT_DIR,
-- the specified PCH path should be relative to the location.

	function suite.searchesIncludeDirs_location()
		location "MyProject"
		pchheader "premake.h"
		includedirs { "src/host" }
		prepareVars()
		test.capture [[
PCH = ../src/host/premake.h
		]]
	end


--
-- Verify the format of the PCH rules block for a C++ file.
--

	function suite.buildRules_onCpp()
		pchheader "include/myproject.h"
		prepareRules()
		test.capture [[
ifneq (,$(PCH))
$(OBJECTS): $(GCH) | $(PCH_PLACEHOLDER)
$(GCH): $(PCH) | prebuild
	@echo $(notdir $<)
	$(SILENT) $(CXX) -x c++-header $(ALL_CXXFLAGS) -o "$@" -c "$<"
$(PCH_PLACEHOLDER): $(GCH) | $(OBJDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) touch "$@"
else
	$(SILENT) echo $null >> "$@"
endif
else
$(OBJECTS): | prebuild
endif
		]]
	end


--
-- Verify the format of the PCH rules block for a C file.
--

	function suite.buildRules_onC()
		language "C"
		pchheader "include/myproject.h"
		prepareRules()
		test.capture [[
ifneq (,$(PCH))
$(OBJECTS): $(GCH) | $(PCH_PLACEHOLDER)
$(GCH): $(PCH) | prebuild
	@echo $(notdir $<)
	$(SILENT) $(CC) -x c-header $(ALL_CFLAGS) -o "$@" -c "$<"
$(PCH_PLACEHOLDER): $(GCH) | $(OBJDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) touch "$@"
else
	$(SILENT) echo $null >> "$@"
endif
else
$(OBJECTS): | prebuild
endif
		]]
	end

--
-- If the header is located on one of the include file
-- search directories, it should get found automatically.
--

	function suite.PCHFlag()
		pchheader "include/myproject.h"

		files { 'a.cpp', 'b.cpp' }

		prepareFlags()
		test.capture [[
# File Rules
# #############################################

$(OBJDIR)/a.o: a.cpp
	@echo "$(notdir $<)"
	$(SILENT) $(CXX) -include $(PCH_PLACEHOLDER) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -c "$<"
$(OBJDIR)/b.o: b.cpp
	@echo "$(notdir $<)"
	$(SILENT) $(CXX) -include $(PCH_PLACEHOLDER) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -c "$<"
]]
	end

	function suite.PCHFlag_PerFile()
		pchheader "include/myproject.h"

		files { 'a.cpp', 'b.cpp' }

		filter { "files:a.cpp" }
			flags "NoPCH"

		prepareFlags()
		test.capture [[
# File Rules
# #############################################

$(OBJDIR)/a.o: a.cpp
	@echo "$(notdir $<)"
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -c "$<"
$(OBJDIR)/b.o: b.cpp
	@echo "$(notdir $<)"
	$(SILENT) $(CXX) -include $(PCH_PLACEHOLDER) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -c "$<"
]]
	end

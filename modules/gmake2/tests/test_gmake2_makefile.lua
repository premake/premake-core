--
-- test_gmake2_makefile.lua
-- Validate the makefile projects.
-- (c) 2016-2017 Jason Perkins, Blizzard Entertainment and the Premake project
--

  local p = premake
  local suite = test.declare("gmake2_makefile")

  local p = premake
  local gmake2 = p.modules.gmake2

  local project = p.project


--
-- Setup
--

  local wks, prj

  function suite.setup()
    wks, prj = test.createWorkspace()
  end

  local function prepare()
    local cfg = test.getconfig(prj, "Debug")
    kind "Makefile"
    gmake2.cpp.allRules(cfg)
  end


--
-- Check rules for Makefile projects.
--

  function suite.makefile_configs_empty()
    kind "Makefile"

    prj = test.getproject(wks, 1)
    gmake2.makefile.configs(prj)
    test.capture [[
ifeq ($(config),debug)
TARGETDIR = bin/Debug
TARGET = $(TARGETDIR)/MyProject
  define BUILDCMDS
  endef
  define CLEANCMDS
  endef

else ifeq ($(config),release)
TARGETDIR = bin/Release
TARGET = $(TARGETDIR)/MyProject
  define BUILDCMDS
  endef
  define CLEANCMDS
  endef

else
  $(error "invalid configuration $(config)")
endif
    ]]
  end

  function suite.makefile_configs_commands()
    kind "Makefile"

    prj = test.getproject(wks, 1)

    buildcommands {
      "touch source"
    }

    cleancommands {
      "rm -f source"
    }


    gmake2.makefile.configs(prj)
    test.capture [[
ifeq ($(config),debug)
TARGETDIR = bin/Debug
TARGET = $(TARGETDIR)/MyProject
  define BUILDCMDS
	@echo Running build commands
	touch source
  endef
  define CLEANCMDS
	@echo Running clean commands
	rm -f source
  endef

else ifeq ($(config),release)
TARGETDIR = bin/Release
TARGET = $(TARGETDIR)/MyProject
  define BUILDCMDS
	@echo Running build commands
	touch source
  endef
  define CLEANCMDS
	@echo Running clean commands
	rm -f source
  endef

else
  $(error "invalid configuration $(config)")
endif
    ]]
  end

--
-- test_gmake2_makefile.lua
-- Validate the makefile projects.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
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
    kind "Makefile"
  end

  local function prepare()
    prj = test.getproject(wks, 1)
    gmake2.makefile.configs(prj)
  end


--
-- Check rules for Makefile projects.
--

  function suite.makefile_configs_empty()
    prepare()
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
    buildcommands {
      "touch source"
    }

    cleancommands {
      "rm -f source"
    }

    prepare()
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

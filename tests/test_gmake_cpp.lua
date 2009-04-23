--
-- tests/test_gmake_cpp.lua
-- Automated test suite for GNU Make C/C++ project generation.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.gmake_cpp = { }

--
-- Configure a solution for testing
--

	local sln, prj
	function T.gmake_cpp.setup()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms { "native", "x64" }
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		
		_ACTION = "gmake"
		_OPTIONS.cc = "gcc"
		_OPTIONS.os = "linux"
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
	end
	


	function T.gmake_cpp.BasicCfgBlock()
		prepare()
		local cfg = premake.getconfig(prj, "Debug")
		premake.gmake_cpp_config(cfg)
		test.capture [[
ifeq ($(config),debug)
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/MyProject
  OBJDIR     = obj/Debug
  DEFINES   += 
  INCLUDES  += 
  CPPFLAGS  += -MMD $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) 
  CXXFLAGS  += $(CFLAGS) 
  LDFLAGS   += -s  
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += 
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif
		]]
	end



	function T.gmake_cpp.PlatformSpecificBlock()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x64")
		premake.gmake_cpp_config(cfg)
		test.capture [[
ifeq ($(config),debug64)
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/MyProject
  OBJDIR     = obj/x64/Debug
  DEFINES   += 
  INCLUDES  += 
  CPPFLAGS  += -MMD $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -m64
  CXXFLAGS  += $(CFLAGS) 
  LDFLAGS   += -s -m64 -L/usr/lib64
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += 
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif
		]]
	end

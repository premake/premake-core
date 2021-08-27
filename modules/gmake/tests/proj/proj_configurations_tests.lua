local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationsTests = test.declare('GmakeProjConfigurationsTests', 'gmake-proj', 'gmake')


---
-- Tests setting the default target directory for gmake.
---
function GmakeProjConfigurationsTests.DefaultTargetDir()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configTargetDir(cfg)

	test.capture [[
TARGETDIR = bin/MyProject/Debug
	]]
end


---
-- Tests setting the default intermediate directory for gmake.
---
function GmakeProjConfigurationsTests.DefaultIntermediateDir()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configIntermediateDir(cfg)

	test.capture [[
OBJDIR = obj/MyProject/Debug
	]]
end


---
-- Tests setting the default target name for gmake.
---
function GmakeProjConfigurationsTests.DefaultTargetName()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configTargetName(cfg)

	test.capture [[
	]]
end


---
-- Tests setting the defines for gmake.
---
function GmakeProjConfigurationsTests.DefaultDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configDefines(cfg)

	test.capture [[
	]]
end


---
-- Tests setting project wide defines.
---
function GmakeProjConfigurationsTests.ProjectDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			defines({ 'MY_DEFINE' })
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configDefines(cfg)

	test.capture [[
	]]
end


---
-- Tests setting configuration-wide defines.
---
function GmakeProjConfigurationsTests.ConfigurationDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			when({ 'configurations:Debug' }, function ()
				defines('MY_DEFINE')
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configDefines(cfg)

	test.capture [[
DEFINES += -DMY_DEFINE
	]]
end


---
-- Tests setting configuration-wide defines, but for another configuration.
---
function GmakeProjConfigurationsTests.ConfigurationDefinesOtherConfiguration()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug', 'Release' })

		project('MyProject', function ()
			when({ 'configurations:Release' }, function ()
				defines('MY_DEFINE')
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configDefines(cfg)

	test.capture [[
	]]
end


---
-- Tests the CFLAGS output with the default GCC flags.
---
function GmakeProjConfigurationsTests.DefaultCFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configCFlags(cfg)

	test.capture [[
ALL_CFLAGS += -m64
	]]
end


---
-- Tests the CPPFLAGS output with the default GCC flags.
---
function GmakeProjConfigurationsTests.DefaultCppFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configCppFlags(cfg)

	test.capture [[
	]]
end


---
-- Tests the CXXFLAGS output with the default GCC flags.
---
function GmakeProjConfigurationsTests.DefaultCxxFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configCxxFlags(cfg)

	test.capture [[
ALL_CXXFLAGS += -m64
	]]
end


---
-- Tests INCLUDE output with no includes.
---
function GmakeProjConfigurationsTests.DefaultIncludes()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configIncludeDirs(cfg)

	test.capture [[
	]]
end


---
-- Tests INCLUDE outputs with an include directory.
---
function GmakeProjConfigurationsTests.NoIncludeDirs()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			includeDirs({
				'include/'
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configIncludeDirs(cfg)

	test.capture [[
	]]
end


---
-- Tests INCLUDE outputs with an include directory.
---
function GmakeProjConfigurationsTests.includeDirs()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			when({ 'configurations:Debug' }, function ()
				includeDirs({
					'include/'
				})
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configIncludeDirs(cfg)

	test.capture [[
INCLUDES += -Iinclude
	]]
end


---
-- Tests the LDFLAGS output.
---
function GmakeProjConfigurationsTests.DefaultLinkFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configLinkFlags(cfg)

	test.capture[[
ALL_LDFLAGS += -m64 -L/usr/lib64
	]]
end


---
-- Tests the default output of the custom build commands.
---
function GmakeProjConfigurationsTests.DefaultBuildCmds()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configBuildCommands(cfg)

	test.capture [[
define PREBUILDCMDS
endef
define PRELINKCMDS
endef
	]]
end
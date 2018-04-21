---
-- tests/oven/test_compilebuildoutputstarget.lua
-- Test the per-configuration object directory assignments.
-- Copyright (c) 2014-2018 Jason Perkins and the Premake project
---

	local p = premake
	local suite = test.declare("oven_compilebuildoutputstarget")
	local oven = p.oven

---
-- Setup
---

	local wks, prj

	function suite.setup()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }

		project 'codegen'
		    kind 'Utility'
			removeconfigurations { '*' }
			configurations { 'Codegen' }
			configmap {
				["*"] = "Codegen",
			}

			files { 'test.tag' }

			filter { 'files:**.tag' }
				buildmessage 'Compiling %{file.abspath}'
				buildcommands {
					'copy %{file.abspath} %{sln.location}/generated/%{file.basename}.h'
				}
				buildoutputs {
					'%{sln.location}/generated/%{file.basename}.h',
				}
				compilebuildoutputs 'true'
				compilebuildoutputstarget 'MyProject'

		prj = project 'MyProject'
			kind 'StaticLib'
			dependson 'codegen'
	end

	local function prepare(buildcfg, platform)
		cfg = test.getconfig(prj, buildcfg, platform)
	end

	function suite.test_oven()
		prepare("Debug")
		--test.isequal(path.getabsolute("obj/Debug"), cfg.objdir)

		prepare("Release")
		--test.isequal(path.getabsolute("obj/Release"), cfg.objdir)
	end

--
-- tests/project/test_fileconfig.lua
-- Test the project fileconfig properties.
-- Copyright (c) 2024 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("project_fileconfig")

--
-- Setup and teardown
--

	local wks, prj, cfg

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = test.getWorkspace(wks)
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Check that .m files are compiled as Objective-C.
--

function suite.compile_mFiles_asObjC()
	files { "foo.m" }
	prepare()
	local tr = p.project.getsourcetree(prj)
	p.tree.traverse(tr, {
		-- source files are handled at the leaves
		onleaf = function(node, depth)
			local fcfg = p.fileconfig.getconfig(node, cfg)
			test.isequal(p.OBJECTIVEC, fcfg.compileas)
		end,
	}, true)
end


--
-- Check that .mm files are compiled as Objective-C++.
--

	function suite.compile_mmFiles_asObjCPP()
		files { "foo.mm" }
		prepare()
		local tr = p.project.getsourcetree(prj)
		p.tree.traverse(tr, {
			-- source files are handled at the leaves
			onleaf = function(node, depth)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				test.isequal(p.OBJECTIVECPP, fcfg.compileas)
			end,
		}, true)
	end

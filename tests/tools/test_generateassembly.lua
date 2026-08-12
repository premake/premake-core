-- tests/tools/test_generateassembly.lua
-- Test generateassembly compiler flags.

	local p = premake
	local suite = test.declare("test_generateassembly")

	local gcc = p.tools.gcc
	local clang = p.tools.clang
	local msc = p.tools.msc
	local wks, prj, cfg, filecfg

	function suite.setup()
		wks, prj = test.createWorkspace()
		system "Linux"
		files { "main.cpp" }
	end

	local function prepare(toolsetName)
		if toolsetName then
			toolset(toolsetName)
		end
		cfg = test.getconfig(prj, "Debug")
		local node = p.project.getsourcetree(cfg.project).children["main.cpp"]
		filecfg = p.fileconfig.getconfig(node, cfg)
	end

	function suite.gccOn()
		filter "files:main.cpp"
		generateassembly "On"
		prepare("gcc")
		test.isnil(cfg.generateassembly)
		test.isequal("On", filecfg.generateassembly)
		test.contains("-save-temps=obj", gcc.getassemblyflags(filecfg))
	end

	function suite.configValueUsedWhenFileUnset()
		generateassembly "On"
		prepare("gcc")
		test.isequal("On", cfg.generateassembly)
		test.isnil(filecfg.generateassembly)
		test.contains("-save-temps=obj", gcc.getassemblyflags(cfg))
	end

	function suite.gccVerbose()
		filter "files:main.cpp"
		generateassembly "Verbose"
		prepare("gcc")
		test.contains({ "-save-temps=obj", "-fverbose-asm" }, gcc.getassemblyflags(filecfg))
	end

	function suite.clangVerbose()
		filter "files:main.cpp"
		generateassembly "Verbose"
		prepare("clang")
		test.contains({ "-save-temps=obj", "-fverbose-asm" }, clang.getassemblyflags(filecfg))
	end

	function suite.mscOn()
		filter "files:main.cpp"
		generateassembly "On"
		prepare("msc")
		test.contains({ "/FA", '/Fa"main.asm"' }, msc.getassemblyflags(filecfg, '"main.asm"'))
		test.isequal("main.asm", msc.getassemblyoutput(filecfg, "main.obj"))
	end

	function suite.mscVerbose()
		filter "files:main.cpp"
		generateassembly "Verbose"
		prepare("msc")
		test.contains("/FAs", msc.getassemblyflags(filecfg))
	end

	function suite.off()
		generateassembly "On"
		filter "files:main.cpp"
		generateassembly "Off"
		prepare("gcc")
		test.isequal("On", cfg.generateassembly)
		test.isequal("Off", filecfg.generateassembly)
		test.excludes({ "-save-temps=obj", "-fverbose-asm" }, gcc.getassemblyflags(filecfg))
	end

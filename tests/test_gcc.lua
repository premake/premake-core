--
-- tests/test_gcc.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.gcc = { }

	local cfg
	function T.gcc.setup()
		cfg = { }
		cfg.basedir    = "."
		cfg.location   = "."
		cfg.language   = "C++"
		cfg.project    = { name = "MyProject" }
		cfg.flags      = { }
		cfg.objectsdir = "obj"
		cfg.platform   = "Native"
		cfg.links      = { }
		cfg.libdirs    = { }
	end


	function T.gcc.cflags_SharedLib_Windows()
		cfg.kind = "SharedLib"
		cfg.system = "windows"
		local r = premake.gcc.getcflags(cfg)
		test.isequal('', table.concat(r,"|"))
	end

	function T.gcc.ldflags_SharedLib_Windows()
		cfg.kind = "SharedLib"
		cfg.system = "windows"
		local r = premake.gcc.getldflags(cfg)
		test.isequal('-s|-shared|-Wl,--out-implib="libMyProject.a"', table.concat(r,"|"))
	end

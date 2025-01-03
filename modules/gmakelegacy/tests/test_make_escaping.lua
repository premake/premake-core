--
-- tests/actions/make/test_make_escaping.lua
-- Validate the escaping of literal values in Makefiles.
-- Copyright (c) 2010-2012 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_escaping")
	local make = p.makelegacy


	function suite.Escapes_Spaces()
		test.isequal([[Program\ Files]], make.esc([[Program Files]]))
	end

	function suite.Escapes_Backslashes()
		test.isequal([[Program\\Files]], make.esc([[Program\Files]]))
	end

	function suite.Escapes_Parens()
		test.isequal([[Debug\(x86\)]], make.esc([[Debug(x86)]]))
	end

	function suite.DoesNotEscape_ShellReplacements()
		test.isequal([[-L$(NVSDKCUDA_ROOT)/C/lib]], make.esc([[-L$(NVSDKCUDA_ROOT)/C/lib]]))
	end

	function suite.CanEscape_ShellReplacementCapturesShortest()
		test.isequal([[a\(x\)b$(ROOT)c\(y\)d]], make.esc([[a(x)b$(ROOT)c(y)d]]))
	end


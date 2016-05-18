---
-- test_hooks.lua
--
-- Wire into the Lua runtime environment to support testing.
--
-- Author Jason Perkins
-- Copyright (c) 2008-2016 Jason Perkins and the Premake project.
---

	local p = premake
	local m = p.modules.self_test

	local _ = {}


	function m.installTestingHooks()
		local hooks = {}

		hooks.io_open = io.open
		hooks.io_output = io.output
		hooks.os_writefile_ifnotequal = os.writefile_ifnotequal
		hooks.p_utf8 = p.utf8
		hooks.print = print

		io.open = _.stub_io_open
		io.output = _.stub_io_output
		os.writefile_ifnotequal = _.stub_os_writefile_ifnotequal
		print = _.stub_print
		p.utf8 = _.stub_utf8

		return hooks
	end



	function m.removeTestingHooks(hooks)
		io.open = hooks.io_open
		io.output = hooks.io_output
		os.writefile_ifnotequal = hooks.os_writefile_ifnotequal
		p.utf8 = hooks.p_utf8
		print = hooks.print
	end



	function _.stub_io_open(fname, mode)
		test.value_openedfilename = fname
		test.value_openedfilemode = mode
		return {
			close = function()
				test.value_closedfile = true
			end
		}
	end



	function _.stub_io_output(f)
	end



	function _.stub_os_writefile_ifnotequal(content, fname)
		m.value_openedfilename = fname
		m.value_closedfile = true
		return 0
	end



	function _.stub_print(s)
	end



	function _.stub_utf8()
	end

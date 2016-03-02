--
-- tests/base/test_module_loader.lua
-- Test the custom module loader.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("module_loader")

--
-- Setup
--

	local loaderIndex

	function suite.setup()
		table.insert(package.searchers, function (name)
			p.out(name)
			return load("")
		end)
		loaderIndex = #package.searchers
	end

	function suite.teardown()
		table.remove(package.searchers, loaderIndex)
	end

--
-- Check that premake's module loader let other loaders try
-- when it cannot find a module.
--

	function suite.letOtherLoadersTry()
		require("foo")
		test.capture [[
foo
		]]
	end

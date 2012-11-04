--
-- tests/base/test_configset.lua
-- Test suite for the configset API.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.configset = {}
	local suite = T.configset

	local configset = premake.configset


--
-- Setup and teardown
--

	local cset, parentset
	
	function suite.setup()
		parentset = configset.new()
		cset = configset.new(parentset)
	end


--
-- Make sure that new() returns a valid object.
--

	function suite.new_returnsValidObject()
		test.isequal("table", type(cset))
	end


--
-- Check the default values for different field types.
--

	function suite.defaultValue_onString()
		test.isnil(configset.fetchvalue(cset, "targetextension", {}))
	end


--
-- Make sure that I can roundtrip a value stored into the
-- initial, default configuration.
--

	function suite.canRoundtrip_onDefaultBlock()
		configset.addvalue(cset, "targetextension", ".so")
		test.isequal(".so", configset.fetchvalue(cset, "targetextension", {}))
	end

	function suite.canRoundtrip_onDefaultBlock_usingDirectSet()
		cset.targetextension = ".so"
		test.isequal(".so", configset.fetchvalue(cset, "targetextension", {}))
	end


--
-- Make sure that I can roundtrip a value stored into a block 
-- with a simple matching term.
--

	function suite.canRoundtrip_onSimpleTermMatch()
		configset.addblock(cset, { "Windows" })
		configset.addvalue(cset, "targetextension", ".dll")
		test.isequal(".dll", configset.fetchvalue(cset, "targetextension", { "windows" }))
	end

	function suite.canRoundtrip_onSimpleTermMatch_usingDirectGet()
		configset.addblock(cset, { "Windows" })
		configset.addvalue(cset, "targetextension", ".dll")
		test.isequal(".dll", cset.targetextension)
	end


--
-- Make sure that blocks that do not match the context terms
-- do not contribute to the result.
--

	function suite.skipsBlock_onTermMismatch()
		configset.addvalue(cset, "targetextension", ".so")		
		configset.addblock(cset, { "Windows" })
		configset.addvalue(cset, "targetextension", ".dll")
		test.isequal(".so", configset.fetchvalue(cset, "targetextension", { "linux" }))
	end


--
-- Values stored in a parent configuration set should propagate into child.
--

	function suite.canRoundtrip_fromParentToChild()
		configset.addvalue(parentset, "targetextension", ".so")
		test.isequal(".so", configset.fetchvalue(cset, "targetextension", {}))
	end


--
-- Child should be able to override parent values.
--

	function suite.child_canOverrideStringValueFromParent()
		configset.addvalue(parentset, "targetextension", ".so")
		configset.addvalue(cset, "targetextension", ".dll")
		test.isequal(".dll", configset.fetchvalue(cset, "targetextension", {}))
	end


--
-- If a base directory is set, filename tests should be performed
-- relative to this path.
--

	function suite.filenameMadeRelative_onBaseDirSet()
		configset.addblock(cset, { "hello.c" }, os.getcwd())
		configset.addvalue(cset, "buildaction", "copy")
		test.isequal("copy", configset.fetchvalue(cset, "buildaction", {}, path.join(os.getcwd(), "hello.c")))
	end

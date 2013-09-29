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


--
-- List fields should return an empty list of not set.
--

     function suite.lists_returnsEmptyTable_onNotSet()
          test.isequal({}, configset.fetchvalue(cset, "buildoptions", {}))
     end


--
-- List fields should merge values fetched from different blocks.
--

	function suite.lists_mergeValues_onFetch()
		configset.addvalue(cset, "buildoptions", "v1")
		configset.addblock(cset, { "windows" })
		configset.addvalue(cset, "buildoptions", "v2")
		test.isequal({"v1", "v2"}, configset.fetchvalue(cset, "buildoptions", {"windows"}))
	end


--
-- Multiple adds to a list field in the same block should be merged together.
--

	function suite.lists_mergeValues_onAdd()
		configset.addvalue(cset, "buildoptions", "v1")
		configset.addvalue(cset, "buildoptions", "v2")
		test.isequal({"v1", "v2"}, configset.fetchvalue(cset, "buildoptions", {"windows"}))
	end


--
-- Fetched lists should be both keyed and indexed.
--

	function suite.lists_includeValueKeys()
		configset.addvalue(cset, "buildoptions", { "v1", "v2" })
		local x = configset.fetchvalue(cset, "buildoptions", {})
		test.isequal("v2", x.v2)
	end


--
-- Check removing a value with an exact match.
--

	function suite.remove_onExactValueMatch()
		configset.addvalue(cset, "flags", { "Symbols", "Unsafe", "NoRTTI" })
		configset.removevalues(cset, "flags", { "Unsafe" })
		test.isequal({ "Symbols", "NoRTTI" }, configset.fetchvalue(cset, "flags", {}))
	end

	function suite.remove_onMultipleValues()
		configset.addvalue(cset, "flags", { "Symbols", "NoExceptions", "Unsafe", "NoRTTI" })
		configset.removevalues(cset, "flags", { "NoExceptions", "NoRTTI" })
		test.isequal({ "Symbols", "Unsafe" }, configset.fetchvalue(cset, "flags", {}))
	end


--
-- Remove should also accept wildcards.
--

	function suite.remove_onWildcard()
		configset.addvalue(cset, "defines", { "WIN32", "WIN64", "LINUX", "MACOSX" })
		configset.removevalues(cset, "defines", { "WIN*" })
		test.isequal({ "LINUX", "MACOSX" }, configset.fetchvalue(cset, "defines", {}))
	end


--
-- Keyed values should merge keys fetched from different blocks.
--

	function suite.keyed_mergesKeys_onFetch()
		configset.addvalue(cset, "configmap", { Debug="Debug", Release="Release" })
		configset.addblock(cset, { "windows" })
		configset.addvalue(cset, "configmap", { Profile="Profile" })
		local x = configset.fetchvalue(cset, "configmap", {"windows"})
		test.istrue(x.Debug and x.Release and x.Profile)
	end


--
-- Multiple adds to a keyed value field in the same block should be merged.
--

	function suite.keyed_mergesKeys_onAdd()
		configset.addvalue(cset, "configmap", { Debug="Debug", Release="Release" })
		configset.addvalue(cset, "configmap", { Profile="Profile" })
		local x = configset.fetchvalue(cset, "configmap", {"windows"})
		test.istrue(x.Debug and x.Release and x.Profile)
	end


--
-- Keyed values should overwrite when non-merged fields are fetched.
--

	function suite.keyed_overwritesValues_onNonMergeFetch()
		configset.addvalue(cset, "configmap", { Debug="Debug" })
		configset.addblock(cset, { "windows" })
		configset.addvalue(cset, "configmap", { Debug="Development" })
		local x = configset.fetchvalue(cset, "configmap", {"windows"})
		test.isequal("Development", x.Debug)
	end

	function suite.keyed_overwritesValues_onNonMergeAdd()
		configset.addvalue(cset, "configmap", { Debug="Debug" })
		configset.addvalue(cset, "configmap", { Debug="Development" })
		local x = configset.fetchvalue(cset, "configmap", {"windows"})
		test.isequal("Development", x.Debug)
	end


--
-- Keyed values should merge when merged fields are fetched.
--

	function suite.keyed_mergesValues_onMergeFetch()
		configset.addvalue(cset, "vpaths", { includes="*.h" })
		configset.addblock(cset, { "windows" })
		configset.addvalue(cset, "vpaths", { includes="*.hpp" })
		local x = configset.fetchvalue(cset, "vpaths", {"windows"})
		test.isequal({ "*.h", "*.hpp" }, x.includes)
	end

	function suite.keyed_mergesValues_onMergeAdd()
		configset.addvalue(cset, "vpaths", { includes="*.h" })
		configset.addvalue(cset, "vpaths", { includes="*.hpp" })
		local x = configset.fetchvalue(cset, "vpaths", {"windows"})
		test.isequal({ "*.h", "*.hpp" }, x.includes)
	end

--
-- tests/base/test_configset.lua
-- Test suite for the configset API.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("configset")
	local configset = p.configset
	local field = p.field


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
		test.isnil(configset.fetch(cset, field.get("targetextension")))
	end

	function suite.defaultValue_onList()
		test.isequal({}, configset.fetch(cset, field.get("defines")))
	end



--
-- Make sure that I can roundtrip a value stored into the
-- initial, default configuration.
--

	function suite.canRoundtrip_onDefaultBlock()
		local f = field.get("targetextension")
		configset.store(cset, f, ".so")
		test.isequal(".so", configset.fetch(cset, f, {}))
	end



--
-- Make sure that I can roundtrip a value stored into a block
-- with a simple matching term.
--

	function suite.canRoundtrip_onSimpleTermMatch()
		local f = field.get("targetextension")
		configset.addblock(cset, { "Windows" })
		configset.store(cset, f, ".dll")
		test.isequal(".dll", configset.fetch(cset, f, { "windows" }))
	end


--
-- Make sure that blocks that do not match the context terms
-- do not contribute to the result.
--

	function suite.skipsBlock_onTermMismatch()
		local f = field.get("targetextension")
		configset.store(cset, f, ".so")
		configset.addblock(cset, { "Windows" })
		configset.store(cset, f, ".dll")
		test.isequal(".so", configset.fetch(cset, f, { "linux" }))
	end


--
-- Values stored in a parent configuration set should propagate into child.
--

	function suite.canRoundtrip_fromParentToChild()
		local f = field.get("targetextension")
		configset.store(parentset, f, ".so")
		test.isequal(".so", configset.fetch(cset, f, {}))
	end


--
-- Child should be able to override parent values.
--

	function suite.child_canOverrideStringValueFromParent()
		local f = field.get("targetextension")
		configset.store(parentset, f, ".so")
		configset.store(cset, f, ".dll")
		test.isequal(".dll", configset.fetch(cset, f, {}))
	end


--
-- If a base directory is set, filename tests should be performed
-- relative to this path.
--

	function suite.filenameMadeRelative_onBaseDirSet()
		local f = field.get("buildaction")
		configset.addblock(cset, { "hello.c" }, os.getcwd())
		configset.store(cset, f, "Copy")
		test.isequal("Copy", configset.fetch(cset, f, { files=path.join(os.getcwd(), "hello.c"):lower() }))
	end


--
-- List fields should return an empty list of not set.
--

	function suite.lists_returnsEmptyTable_onNotSet()
		test.isequal({}, configset.fetch(cset, field.get("buildoptions"), {}))
	end


--
-- List fields should merge values fetched from different blocks.
--

	function suite.lists_mergeValues_onFetch()
		local f = field.get("buildoptions")
		configset.store(cset, f, "v1")
		configset.addblock(cset, { "windows" })
		configset.store(cset, f, "v2")
		test.isequal({"v1", "v2"}, configset.fetch(cset, f, {"windows"}))
	end


--
-- Multiple adds to a list field in the same block should be merged together.
--

	function suite.lists_mergeValues_onAdd()
		local f = field.get("buildoptions")
		configset.store(cset, f, "v1")
		configset.store(cset, f, "v2")
		test.isequal({"v1", "v2"}, configset.fetch(cset, f, {"windows"}))
	end


--
-- Fetched lists should be both keyed and indexed.
--

	function suite.lists_includeValueKeys()
		local f = field.get("buildoptions")
		configset.store(cset, f, { "v1", "v2" })
		local x = configset.fetch(cset, f, {})
		test.isequal("v2", x.v2)
	end


--
-- Check removing a value with an exact match.
--

	function suite.remove_onExactValueMatch()
		local f = field.get("flags")
		configset.store(cset, f, { "Symbols", "WinMain", "MFC" })
		configset.remove(cset, f, { "WinMain" })
		test.isequal({ "Symbols", "MFC" }, configset.fetch(cset, f, {}))
	end

	function suite.remove_onMultipleValues()
		local f = field.get("flags")
		configset.store(cset, f, { "Symbols", "Maps", "WinMain", "MFC" })
		configset.remove(cset, f, { "Maps", "MFC" })
		test.isequal({ "Symbols", "WinMain" }, configset.fetch(cset, f, {}))
	end


--
-- Remove should also accept wildcards.
--

	function suite.remove_onWildcard()
		local f = field.get("defines")
		configset.store(cset, f, { "WIN32", "WIN64", "LINUX", "MACOSX" })
		configset.remove(cset, f, { "WIN*" })
		test.isequal({ "LINUX", "MACOSX" }, configset.fetch(cset, f, {}))
	end


--
-- Keyed values should merge keys fetched from different blocks.
--

	function suite.keyed_mergesKeys_onFetch()
		local f = field.get("configmap")
		configset.store(cset, f, { Debug="Debug", Release="Release" })
		configset.addblock(cset, { "windows" })
		configset.store(cset, f, { Profile="Profile" })
		local x = configset.fetch(cset, f, {"windows"})
		test.istrue(x[1].Debug and x[1].Release and x[2].Profile)
	end


--
-- Multiple adds to a keyed value field in the same block should be merged.
--

	function suite.keyed_mergesKeys_onAdd()
		local f = field.get("configmap")
		configset.store(cset, f, { Debug="Debug", Release="Release" })
		configset.store(cset, f, { Profile="Profile" })
		local x = configset.fetch(cset, f, {"windows"})
		test.istrue(x[1].Debug and x[1].Release and x[2].Profile)
	end


--
-- Keyed values should overwrite when non-merged fields are fetched.
--

	function suite.keyed_overwritesValues_onNonMergeFetch()
		local f = field.get("configmap")
		configset.store(cset, f, { Debug="Debug" })
		configset.addblock(cset, { "windows" })
		configset.store(cset, f, { Debug="Development" })
		local x = configset.fetch(cset, f, {"windows"})
		test.isequal({"Development"}, x[2].Debug)
	end

	function suite.keyed_overwritesValues_onNonMergeAdd()
		local f = field.get("configmap")
		configset.store(cset, f, { Debug="Debug" })
		configset.store(cset, f, { Debug="Development" })
		local x = configset.fetch(cset, f, {"windows"})
		test.isequal({"Development"}, x[2].Debug)
	end

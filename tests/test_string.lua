--
-- tests/test_string.lua
-- Automated test suite for the new string functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	local suite = test.declare("string")


--
-- string.endswith() tests
--

	function suite.endswith_ReturnsTrue_OnMatch()
		test.istrue(string.endswith("Abcdef", "def"))
	end

	function suite.endswith_ReturnsFalse_OnMismatch()
		test.isfalse(string.endswith("Abcedf", "efg"))
	end
	
	function suite.endswith_ReturnsFalse_OnLongerNeedle()
		test.isfalse(string.endswith("Abc", "Abcdef"))
	end
	
	function suite.endswith_ReturnsFalse_OnNilHaystack()
		test.isfalse(string.endswith(nil, "ghi"))
	end

	function suite.endswith_ReturnsFalse_OnNilNeedle()
		test.isfalse(string.endswith("Abc", nil))
	end
	
	function suite.endswith_ReturnsTrue_OnExactMatch()
		test.istrue(string.endswith("/", "/"))
	end



--
-- string.explode() tests
--

	function suite.explode_ReturnsParts_OnValidCall()
		test.isequal({"aaa","bbb","ccc"}, string.explode("aaa/bbb/ccc", "/", true))
	end



--
-- string.startswith() tests
--

	function suite.startswith_OnMatch()
		test.istrue(string.startswith("Abcdef", "Abc"))
	end

	function suite.startswith_OnMismatch()
		test.isfalse(string.startswith("Abcdef", "ghi"))
	end

	function suite.startswith_OnLongerNeedle()
		test.isfalse(string.startswith("Abc", "Abcdef"))
	end

	function suite.startswith_OnEmptyHaystack()
		test.isfalse(string.startswith("", "Abc"))
	end

	function suite.startswith_OnEmptyNeedle()
		test.istrue(string.startswith("Abcdef", ""))
	end

--
-- tests/test_string.lua
-- Automated test suite for the new string functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.string = { }


--
-- string.endswith() tests
--

	function T.string.endswith_ReturnsTrue_OnMatch()
		test.istrue(string.endswith("Abcdef", "def"))
	end

	function T.string.endswith_ReturnsFalse_OnMismatch()
		test.isfalse(string.endswith("Abcedf", "efg"))
	end
	
	function T.string.endswith_ReturnsFalse_OnLongerNeedle()
		test.isfalse(string.endswith("Abc", "Abcdef"))
	end
	
	function T.string.endswith_ReturnsFalse_OnNilHaystack()
		test.isfalse(string.endswith(nil, "ghi"))
	end

	function T.string.endswith_ReturnsFalse_OnNilNeedle()
		test.isfalse(string.endswith("Abc", nil))
	end



--
-- string.explode() tests
--

	function T.string.explode_ReturnsParts_OnValidCall()
		test.isequal({"aaa","bbb","ccc"}, string.explode("aaa/bbb/ccc", "/", true))
	end

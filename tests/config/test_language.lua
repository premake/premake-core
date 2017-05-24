--
-- tests/config/test_language.lua
-- Test the language keyword behavior
-- Copyright (c) 2017 Blizzard Entertainment, Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("config_language")
	local config = p.config

--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("test")
		_TARGET_OS = "windows"

		wks = workspace("MySolution")
			configurations { "Debug", "Release" }
		prj = project("MyProject")
			kind "ConsoleApp"
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
		return cfg.language
	end

--
-- If no language is set, default is C++
--

	function suite.defaultLanguage()
		local lang = prepare()
		test.isequal("C++", lang)
	end


--
-- Specific version.
--

	function suite.specifyVersion()
		language 'C++14'

		local lang = prepare()
		test.isequal("C++14", lang)
	end

--
-- different language.
--

	function suite.specifyLanguage()
		language 'C'

		local lang = prepare()
		test.isequal("C", lang)
	end


--
-- Version specified but later reverted to versionless.
--

	function suite.specifyVersionThenJustBase()
		language 'C++14'
		language 'C++'

		local lang = prepare()
		test.isequal("C++14", lang)
	end

	function suite.specifyVersionThenJustBaseInFilter()
		language 'C++14'
		filter { "configurations:Debug" }
			language 'C++'
		filter { "configurations:Release" }
			language 'C++11'

		local lang = test.getconfig(prj, "Debug").language
		test.isequal("C++14", lang)

		lang = test.getconfig(prj, "Release").language
		test.isequal("C++11", lang)
	end


	function suite.specifyDifferentLanguage()
		language 'C++14'
		language 'C'

		local lang = prepare()
		test.isequal("C", lang)
	end

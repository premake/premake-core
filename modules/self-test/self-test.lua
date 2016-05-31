---
-- self-test/self-test.lua
--
-- An automated test framework for Premake and its add-on modules.
--
-- Author Jason Perkins
-- Copyright (c) 2008-2016 Jason Perkins and the Premake project.
---


	local p = premake

	p.modules.self_test = {}
	local m = p.modules.self_test

	m._VERSION = p._VERSION

	

	newaction {
		trigger = "self-test",
		shortname  = "Test Premake",
		description = "Run Premake's own local unit test suites",
		execute = function()
			m.executeSelfTest()
		end
	}



	newoption {
		trigger = "test-only",
		value = "suite[.test]",
		description = "For self-test action; run specific suite or test"
	}



	function m.executeSelfTest()
		m.loadTestsFromManifests()

		local test, err = m.getTestWithIdentifier(_OPTIONS["test-only"])
		if err then
			error(err, 0)
		end

		local startTime = os.clock()

		local passed, failed = m.runTest(test)

		local elapsed = os.clock() - startTime

		printf("%d tests passed, %d failed in %0.02f seconds", passed, failed, elapsed)

		if failed > 0 then
			os.exit(5)
		end
	end



	function m.loadTestsFromManifests()
		local mask = path.join(_MAIN_SCRIPT_DIR, "**/tests/_tests.lua")
		local manifests = os.matchfiles(mask)

		-- TODO: "**" should also match "." but doesn't currently
		local top = path.join(_MAIN_SCRIPT_DIR, "tests/_tests.lua")
		if os.isfile(top) then
			table.insert(manifests, 1, top)
		end

		for i = 1, #manifests do
			local manifest = manifests[i]

			_TESTS_DIR = path.getdirectory(manifest)
	
			local files = dofile(manifest)
			for i = 1, #files do
				local filename = path.join(_TESTS_DIR, files[i])
				dofile(filename)
			end
		end
	end



	dofile("test_assertions.lua")
	dofile("test_declare.lua")
	dofile("test_helpers.lua")
	dofile("test_runner.lua")



	return m

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



	dofile("testfx.lua")

	

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
		local focus = {}
		if _OPTIONS["test"] then
			focus = string.explode(_OPTIONS["test"] or "", ".", true)
		end

		local mask = path.join(_MAIN_SCRIPT_DIR, "**/tests/_tests.lua")

		--

		local manifests = os.matchfiles(mask)

		local top = path.join(_MAIN_SCRIPT_DIR, "tests/_tests.lua")
		if os.isfile(top) then
			table.insert(manifests, 1, top)
		end

		for i = 1, #manifests do
			local manifest = manifests[i]
			_TESTS_DIR = path.getdirectory(manifest)
			local files = dofile(manifest)
			for f = 1, #files do
				dofile(path.join(_TESTS_DIR, files[f]))
			end
		end

		--

		local startTime = os.clock()

		passed, failed = test.runall(focus[1], focus[2])

	    io.write('running time : ',  os.clock() - startTime,'\n')

		msg = string.format("%d tests passed, %d failed", passed, failed)
		if (failed > 0) then
			print(msg)
			os.exit(5)
		else
			print(msg)
		end
	end


	return m

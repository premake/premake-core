---
-- Premake automated test runner.
---

	include "../tests/testfx.lua"


	local focus = {}
	if _OPTIONS["test"] then
		focus = string.explode(_OPTIONS["test"] or "", ".", true)
	end


--
-- Find and load all of the test file manifests
--

	local mask = path.join(_MAIN_SCRIPT_DIR, "**/tests/_manifest.lua")
	local manifests = os.matchfiles(mask)

	-- Hmm, "**" should probably also match against "."?
	local top = path.join(_MAIN_SCRIPT_DIR, "tests/_manifest.lua")
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
-- Run them and show the results
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

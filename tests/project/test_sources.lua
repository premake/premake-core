--
-- tests/project/test_sources.lua
-- Automated test suite for the source tree, including tokens and wildcards.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("project_sources")
	local project = p.project


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()

		-- We change the directory to get nice relative paths
		os.chdir(_SCRIPT_DIR)

		-- Create a token to be used in search paths
		p.api.register { name = "mytoken", kind = "string", scope = "config" }
		mytoken "test"
	end

	function suite.teardown()
		mytoken = nil
	end

	local function run()
		local cfg = test.getconfig(prj, "Debug")

		local files = {}
		for _, file in ipairs(cfg.files) do
			table.insert(files, path.getrelative(os.getcwd(), file))
		end

		return files
	end


--
-- Test single file
--

	function suite.SingleFile()
		files { "test_sources.lua" }
		test.isequal({"test_sources.lua"}, run())
	end

--
-- Test tokens
--

	function suite.SingleFileWithToken()
		files { "%{cfg.mytoken}_sources.lua" }
		test.isequal({"test_sources.lua"}, run())
	end

--
-- Test wildcards
--

	function suite.FilesWithWildcard()
		files { "test_*.lua" }
		test.contains("test_sources.lua", run())
	end

	function suite.FilesWithRecursiveWildcard()
		files { "../**_sources.lua" }
		test.contains("test_sources.lua", run())
	end

--
-- Test wildcards and tokens combined
--

	function suite.FilesWithWildcardAndToken()
		files { "%{cfg.mytoken}_*.lua" }
		test.contains("test_sources.lua", run())
	end

	function suite.FilesWithRecursiveWildcardAndToken()
		files { "../**/%{cfg.mytoken}_sources.lua" }
		test.contains("test_sources.lua", run())
	end

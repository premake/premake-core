--
-- tests/project/test_basedir.lua
-- Test handling of the projects's basedir field.
-- Copyright (c) 2024 Jason Perkins and the Premake project
--

	local suite = test.declare("project_basedir")


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
	end

	local function get_files()
		local cfg = test.getconfig(prj, "Debug")

		local files = {}
		for _, file in ipairs(cfg.files) do
			table.insert(files, file)
		end

		return files
	end

	local function get_includedirs()
		local cfg = test.getconfig(prj, "Debug")

		local dirs = {}
		for _, dir in ipairs(cfg.includedirs) do
			table.insert(dirs, dir)
		end

		return dirs
	end

--
-- If no explicit basedir is set, the location should be set to the
-- directory containing the script which defined the project.
--

	function suite.onNoBaseDir()
		prepare()
		test.isequal(os.getcwd(), prj.basedir)
	end


--
-- If an explicit basedir has been set, use it.
--

	function suite.onBaseDir()
		basedir "base"
		prepare()
		test.isequal(path.join(os.getcwd(), "base"), prj.basedir)
	end


--
-- If multiple basedir are set, make sure the value is overriden correctly.
--

function suite.onMultipleBaseDir()
	basedir "base0"
	basedir "base"
	prepare()
	test.isequal(path.join(os.getcwd(), "base"), prj.basedir)
end

--
-- Files should be set relative to basedir.
-- Tests "file" data kind.
--

	function suite.onFilesBaseDir()
		basedir "base"
		files { "test.cpp" }
		prepare()
		test.isequal({path.join(prj.basedir, "test.cpp")}, get_files())
	end


--
-- Include directories should be set relative to basedir.
-- Tests "directory" data kind.
--

function suite.onIncludeDirsBaseDir()
	basedir "base"
	includedirs { "dir" }
	prepare()
	test.isequal({path.join(prj.basedir, "dir")}, get_includedirs())
end


--
-- If the workspace sets a basedir, and the project does not, it should
-- inherit the value from the workspace.
--

	function suite.projectInheritsWorkspaceBaseDir()
		workspace ()
		basedir "base"
		prepare()
		-- dbg()
		test.isequal(path.join(os.getcwd(), "base"), prj.basedir)
	end

--
-- tests/base/test_filename.lua
-- Verify generation of project/solution/rule filenames.
-- Copyright (c) 2008-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("project_filename")

	local p = premake



--
-- Setup
--

	local sln

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = test.getproject(sln, 1)
	end


--
-- Should return name as an absolute path.
--

	function suite.isAbsolutePath()
		prepare()
		test.isequal(os.getcwd(), path.getdirectory(p.filename(prj)))
	end


--
-- Should use the project name, if no filename was specified.
--

	function suite.isProjectName_onNoFilename()
		prepare()
		test.isequal("MyProject", path.getname(p.filename(prj)))
	end


--
-- Should use filename, if set via API.
--

	function suite.doesUseFilename()
		filename "Howdy"
		prepare()
		test.isequal("Howdy", path.getname(p.filename(prj)))
	end


--
-- Appends file extension, if supplied.
--

	function suite.doesUseExtension()
		prepare()
		test.isequal(".xc", path.getextension(p.filename(prj, ".xc")))
	end


--
-- Should also work with solutions.
--

	function suite.worksWithSolution()
		prepare()
		test.isequal("MySolution", path.getname(p.filename(sln)))
	end


--
-- Value should not propagate down to projects.
--

	function suite.doesNotPropagate()
		solution ("MySolution")
		filename ("Howdy")
		prepare()
		test.isequal("MyProject", path.getname(p.filename(prj)))
	end


--
-- If extension is provided without a leading dot, it should override any
-- project filename.
--

	function suite.canOverrideFilename()
		prepare()
		test.isequal("Makefile", path.getname(p.filename(prj, "Makefile")))
	end

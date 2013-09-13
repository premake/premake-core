--
-- tests/project/test_filename.lua
-- Verify generation of project (and solution) filenames.
-- Copyright (c) 2008-2012 Jason Perkins and the Premake project
--

	T.project_filename = {}
	local suite = T.project_filename

	local project = premake.project


--
-- Setup
--

	local sln

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
	end


--
-- Should return name as an absolute path.
--

	function suite.isAbsolutePath()
		prepare()
		test.isequal(os.getcwd(), path.getdirectory(project.getfilename(prj)))
	end


--
-- Should use the project name, if no filename was specified.
--

	function suite.isProjectName_onNoFilename()
		prepare()
		test.isequal("MyProject", path.getname(project.getfilename(prj)))
	end


--
-- Should use filename, if set via API.
--

	function suite.doesUseFilename()
		filename "Howdy"
		prepare()
		test.isequal("Howdy", path.getname(project.getfilename(prj)))
	end


--
-- Appends file extension, if supplied.
--

	function suite.doesUseExtension()
		prepare()
		test.isequal(".xc", path.getextension(project.getfilename(prj, ".xc")))
	end


--
-- Should also work with solutions.
--

	function suite.worksWithSolution()
		prepare()
		test.isequal("MySolution", path.getname(project.getfilename(sln)))
	end


--
-- Value should not propagate down to projects.
--

	function suite.doesNotPropagate()
		solution ("MySolution")
		filename ("Howdy")
		prepare()
		test.isequal("MyProject", path.getname(project.getfilename(prj)))
	end


--
-- If extension is provided without a leading dot, it should override any
-- project filename.
--

	function suite.canOverrideFilename()
		prepare()
		test.isequal("Makefile", path.getname(project.getfilename(prj, "Makefile")))
	end


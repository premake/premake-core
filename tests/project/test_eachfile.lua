--
-- tests/project/test_eachfile.lua
-- Automated test suite for the file iteration function.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.project_eachfile = { }
	local suite = T.project_eachfile
	local project = premake5.project


--
-- Setup and teardown
--

	local sln, prj
	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare(field)
		if not field then
			field = "fullpath"
		end		
		for file in project.eachfile(prj) do
			_p(2, file[field])
		end
	end


--
-- Sanity check that all files are returned, with project relative paths.
--

	function suite.listsAllFiles()
		files { "hello.h", "hello.c" }
		prepare()
		test.capture [[
		hello.h
		hello.c
		]]
	end

--
-- Ensure that the virtual path field defaults to the real file path.
--

	function suite.vpathsAreNil_onNoVpaths()
		files { "hello.h", "hello.c" }
		prepare("vpath")
		test.capture [[
		hello.h
		hello.c
		]]
	end

--
-- If a virtual path is specified, the vpath field should be set.
--

	function suite.vpathSet_onVpath()
		files { "hello.h", "hello.c" }
		vpaths { Headers = "**.h" }
		prepare("vpath")
		test.capture [[
		Headers/hello.h
		hello.c
		]]
	end

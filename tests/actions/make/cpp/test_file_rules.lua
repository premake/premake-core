--
-- tests/actions/make/cpp/test_file_rules.lua
-- Validate the makefile source building rules.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.make_cpp_file_rules = { }
	local suite = T.make_cpp_file_rules
	local cpp = premake.make.cpp
	local project = premake5.project


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln = test.createsolution()
	end
	
	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cpp.filerules(prj)
	end


--
-- Two files with the same base name should have different object files.
--

	function suite.uniqueObjNames_onBaseNameCollision()
		files { "src/hello.cpp", "src/greetings/hello.cpp" }
		prepare()
		test.capture [[
$(OBJDIR)/hello.o: src/greetings/hello.cpp

$(OBJDIR)/hello1.o: src/hello.cpp

  		]]
	end

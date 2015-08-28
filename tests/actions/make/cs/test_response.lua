--
-- tests/actions/make/cs/test_response.lua
-- Validate the list of objects for a response file used by a makefile.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_cs_response")
	local make = premake.make
	local project = premake.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
	end


--
-- Create a project with a lot of files to force the generation of response files.
-- This makes sure they can be processed in Windows since else we reach the command
-- line length max limit.
--

	function suite.listResponse()
		prepare()
		make.csResponseFile(prj)
		test.capture [[
RESPONSE += $(OBJDIR)/MyProject.rsp
		]]
	end


	function suite.listResponseTargets()
		prepare()
		make.csTargetRules(prj)
		test.capture [[
$(TARGET): $(SOURCES) $(EMBEDFILES) $(DEPENDS) $(RESPONSE)
	$(SILENT) $(CSC) /nologo /out:$@ $(FLAGS) $(REFERENCES) @$(RESPONSE) $(patsubst %,/resource:%,$(EMBEDFILES))
		]]
	end

	function suite.listResponseRules()
		files { "foo.cs", "bar.cs" }
		prepare()
		make.csResponseRules(prj)
		test.capture [[
$(RESPONSE): MyProject.make
	@echo Generating response file
ifeq (posix,$(SHELLTYPE))
	$(SILENT) rm -f $(RESPONSE)
else
	$(SILENT) if exist $(RESPONSE) del $(OBJDIR)\MyProject.rsp
endif
	@echo bar.cs >> $(RESPONSE)
	@echo foo.cs >> $(RESPONSE)
		]]
	end

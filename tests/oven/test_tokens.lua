--
-- tests/oven/test_tokens.lua
-- Test the Premake oven's handling of tokens.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.oven_tokens = { }
	local suite = T.oven_tokens
	local oven = premake5.oven
	local project = premake5.project
	local config = premake5.config


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		premake.api.register { 
			name = "testapi", 
			kind = "string", 
			scope = "config",
			tokens = true
		}

		sln, prj = test.createsolution()
	end

	function suite.teardown()
		testapi = nil
	end
	
	function prepare()
		cfg = project.getconfig(prj, "Debug")
	end


--
-- Verify that solution values can be expanded.
--

	function suite.doesExpandSolutionValues()
		testapi "bin/%{sln.name}"
		prepare()
		test.isequal("bin/MySolution", cfg.testapi)
	end


--
-- Verify that multiple values can be expanded.
--

	function suite.doesExpandMultipleValues()
		testapi "bin/%{prj.name}/%{cfg.buildcfg}"
		prepare()
		test.isequal("bin/MyProject/Debug", cfg.testapi)
	end


--
-- Verify that project level values are expanded too.
--

	function suite.doesExpandTokens_onProjects()
		location "build/%{prj.name}"
		prj = premake.solution.getproject_ng(sln, 1)
		test.isequal(os.getcwd().."/build/MyProject", prj.location)
	end


--
-- Verify that file-specific values are expanded.
--

	function suite.doesExpandTokens_onFileCfg()
		files { "hello.c" }
		configuration "**/hello.c"
			testapi "%{cfg.buildcfg}"
		prepare()
		local fcfg = config.getfileconfig(cfg, os.getcwd().."/hello.c")		
		test.isequal("Debug", fcfg.testapi)
	end


--
-- Verify handling of tokens in a build rule.
--

	function suite.doesExpandFileTokens_inBuildRules()
		files { "shaders/hello.cg" }
		configuration { "**.cg" }
			buildrule {
				commands = {
					"cgc --profile gp5vp %{file.path} -o %{cfg.objdir}/%{file.basename}.gxp",
				},
				outputs = {
					"%{cfg.objdir}/%{file.basename}.o"
				}
			}
		prepare()
		local fcfg = config.getfileconfig(cfg, os.getcwd().."/shaders/hello.cg")
		test.isequal("cgc --profile gp5vp shaders/hello.cg -o obj/hello.gxp", fcfg.buildrule.commands[1])
	end

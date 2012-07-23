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

		sln = test.createsolution()
	end

	function suite.teardown()
		testapi = nil
	end
	
	local function prepare()
		-- some values are only accessible after a full bake
		sln = premake.solution.bake(sln)
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = project.getconfig(prj, "Debug")
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
		test.isequal("cgc --profile gp5vp shaders/hello.cg -o obj/Debug/hello.gxp", fcfg.buildrule.commands[1])
	end


--
-- Make sure that the same token source can be applied to multiple targets.
--

	function suite.canReuseTokenSources()
		files { "shaders/hello.cg", "shaders/goodbye.cg" }
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
		test.isequal("cgc --profile gp5vp shaders/hello.cg -o obj/Debug/hello.gxp", fcfg.buildrule.commands[1])
		fcfg = config.getfileconfig(cfg, os.getcwd().."/shaders/goodbye.cg")
		test.isequal("cgc --profile gp5vp shaders/goodbye.cg -o obj/Debug/goodbye.gxp", fcfg.buildrule.commands[1])
	end


--
-- Verify the global namespace is still accessible.
--

	function suite.canUseGlobalFunctions()
		testapi "%{iif(true, 'a', 'b')}"
		prepare()
		test.isequal("a", cfg.testapi)
	end


--
-- Make sure I can use tokens in the objects directory and targets,
-- which can also be a tokens themselves.
--

	function suite.canUseTokensInObjDir()
		objdir "tmp/%{prj.name}_%{cfg.buildcfg}"
		testapi "%{cfg.objdir}"
		prepare()
		test.isequal("tmp/MyProject_Debug", cfg.testapi)
	end

	function suite.canUseTokensInBuildTarget()
		targetdir "bin/%{prj.name}_%{cfg.buildcfg}"
		testapi "%{cfg.targetdir}"
		prepare()
		test.isequal("bin/MyProject_Debug", cfg.testapi)
	end


--
-- Verify that solution-level values are expanded too.
--

	function suite.canUseTokens_onSolution()
		solution "MySolution"
		location "build/%{sln.name}"
		prepare()
		test.isequal(os.getcwd() .. "/build/MySolution", sln.location)
	end


--
-- Verify that target information is available.
--

	function suite.canAccessBuildTarget()
		_OS = "windows"
		targetdir "%{cfg.buildcfg}"
		testapi "%{cfg.buildtarget.relpath}"
		prepare()
		test.isequal("Debug/MyProject.exe", cfg.testapi)
	end

	function suite.canAccessLinkTarget()
		_OS = "windows"
		kind "SharedLib"
		testapi "%{cfg.linktarget.relpath}"
		prepare()
		test.isequal("MyProject.lib", cfg.testapi)
	end

		
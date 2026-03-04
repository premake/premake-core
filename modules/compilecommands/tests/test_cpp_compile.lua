--
-- test_cpp_compile.lua
-- Validate the generation of C++ compile rules in a Ninja build file.
-- Author: Nick Clark
-- Copyright (c) 2026 Jess Perkins and the Premake project
--

	local suite = test.declare("compilecommands_cpp_compile")

	local p = premake
	local compilecommands = p.modules.compilecommands

	local getstructuredimplicitincludedirs = nil

	local wks, prj
	
	function suite.setup()
		-- Replace the getstructuredimplicitincludedirs function with a stub that returns an empty table to ensure consistent test results
		-- This is necessary because the actual function may return different results based on the environment, which can cause tests to fail unpredictably
		getstructuredimplicitincludedirs = p.tools.clang.getstructuredimplicitincludedirs
		p.tools.clang.getstructuredimplicitincludedirs = function() return {} end

		p.action.set("compilecommands")
		wks, prj = test.createWorkspace()
		language "C++"
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		local cfg = test.getconfig(prj, "Debug")
		return cfg
	end


	function suite.teardown()
		p.tools.clang.getstructuredimplicitincludedirs = getstructuredimplicitincludedirs
	end


	function suite.compile_single_file()
		toolset "clang"
		files { "hello.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/hello.o"),
				},
				output = path.getabsolute("obj/Debug/hello.o"),
			}
		}

		test.isequal(expected, args)
	end

	
	function suite.compile_multiple_files()
		toolset "clang"
		files { "hello.cpp", "world.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/hello.o"),
				},
				output = path.getabsolute("obj/Debug/hello.o"),
			},
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("world.cpp"),
				arguments = {
					"clang++",
					path.getabsolute("world.cpp"),
					"-o",
					path.getabsolute("obj/Debug/world.o"),
				},
				output = path.getabsolute("obj/Debug/world.o"),
			}
		}

		test.isequal(expected, args)
	end


	function suite.compile_single_file_with_define()
		toolset "clang"
		defines { "TEST_DEFINE" }
		files { "hello.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					"-DTEST_DEFINE",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/hello.o"),
				},
				output = path.getabsolute("obj/Debug/hello.o"),
			}
		}

		test.isequal(expected, args)
	end


	function suite.compile_single_file_with_include_dir()
		toolset "clang"
		includedirs { "include" }
		files { "hello.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					"-I",
					"include",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/hello.o"),
				},
				output = path.getabsolute("obj/Debug/hello.o"),
			}
		}

		test.isequal(expected, args)
	end


	function suite.compile_single_file_with_external_include_dir()
		toolset "clang"
		externalincludedirs { "external/include" }
		files { "hello.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					"-isystem",
					"external/include",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/hello.o"),
				},
				output = path.getabsolute("obj/Debug/hello.o"),
			}
		}

		test.isequal(expected, args)
	end


	function suite.compile_single_file_with_include_and_external_include_dirs()
		toolset "clang"
		includedirs { "include" }
		externalincludedirs { "external/include" }
		files { "hello.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					"-I",
					"include",
					"-isystem",
					"external/include",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/hello.o"),
				},
				output = path.getabsolute("obj/Debug/hello.o"),
			}
		}

		test.isequal(expected, args)
	end


	function suite.compile_single_file_with_usages_uses_include_dirs()
		project "prj2"
			usage "PUBLIC"
				includedirs { "prj2/include" }
				externalincludedirs { "prj2/external_include" }

			usage "INTERFACE"
				externalincludedirs { "prj2/interface_external_include" }
		
		project "prj"
			uses { "prj2" }
			files { "hello.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					"-I",
					"prj2/include",
					"-isystem",
					"prj2/external_include",
					"-isystem",
					"prj2/interface_external_include",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/prj/hello.o"),
				},
				output = path.getabsolute("obj/Debug/prj/hello.o"),
			}
		}

		test.isequal(expected, args)
	end


	function suite.compile_single_file_with_buildoptions()
		toolset "clang"
		buildoptions { "-Wall", "-Wextra" }
		files { "hello.cpp" }

		local cfg = prepare()
		local args = compilecommands.generate(wks, "Debug", "")

		local expected = {
			{
				directory = path.getabsolute(prj.location),
				file = path.getabsolute("hello.cpp"),
				arguments = {
					"clang++",
					"-Wall",
					"-Wextra",
					path.getabsolute("hello.cpp"),
					"-o",
					path.getabsolute("obj/Debug/hello.o"),
				},
				output = path.getabsolute("obj/Debug/hello.o"),
			}
		}

		test.isequal(expected, args)
	end

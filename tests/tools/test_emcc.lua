--
-- tests/test_emcc.lua
-- Automated test suite for the emcc toolset interface.
-- Copyright (c) 2024 Premake project
--

local p = premake
local suite = test.declare("tools_emcc")

local emcc = p.tools.emcc


--
-- Setup/teardown
--

local wks, prj, cfg

function suite.setup()
	wks, prj = test.createWorkspace()
	system "emscripten"
end

local function prepare()
	cfg = test.getconfig(prj, "Debug")
end


--
-- Check the selection of tools based on the target system.
--

function suite.tools_onDefault()
	system "emscripten"
	prepare()
	test.isequal("wasm32", cfg.architecture)
	test.isequal("emcc", emcc.gettoolname(cfg, "cc"))
	test.isequal("em++", emcc.gettoolname(cfg, "cxx"))
	test.isequal("emar", emcc.gettoolname(cfg, "ar"))
end

function suite.tools_onWASM64()
	system "emscripten"
	architecture "WASM64"
	prepare()
	test.isequal("wasm64", cfg.architecture)
end

--
-- Verify that toolsetpath overrides the default tool name.
--
function suite.toolsetpathOverridesDefault()
	toolset "emcc"
	toolsetpath("emcc", "cc", "/path/to/my/custom/emcc")
	prepare()
	test.isequal("/path/to/my/custom/emcc", emcc.gettoolname(cfg, "cc"))
end


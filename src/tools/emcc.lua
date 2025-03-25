--
-- emcc.lua
-- Emscripten emcc toolset.
-- Copyright (c) 2024 Premake project
--

local p = premake
local clang = p.tools.clang

p.tools.emcc = table.deepcopy(clang, {})
local emcc = p.tools.emcc

emcc.tools = {
	cc = "emcc",
	cxx = "em++",
	ar = "emar"
}

-- Disable the default clang flags for profiling, since they don't work with emcc.
--
-- TODO: Investigate how to apply --cpuprofiler, --memoryprofiler, and ---threadprofiler
-- flags correctly to emcc builds.
emcc.shared.profile = nil
emcc.ldflags.profile = nil

function emcc.gettoolname(cfg, tool)
	return emcc.tools[tool]
end

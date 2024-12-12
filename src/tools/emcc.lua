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

function emcc.gettoolname(cfg, tool)
	return emcc.tools[tool]
end

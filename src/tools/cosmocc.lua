--
-- cosmocc.lua
-- Cosmopolitan Libc toolset adapter for Premake
-- Copyright (c) 2024 Premake project
--

local p = premake
local gcc = p.tools.gcc

p.tools.cosmocc = table.deepcopy(gcc, {})
local cosmocc = p.tools.cosmocc

function cosmocc.getsharedlibarg(cfg)
    return ""
end

cosmocc.ldflags.kind.SharedLib = cosmocc.getsharedlibarg

cosmocc.tools = {
    cc = "cosmocc",
    cxx = "cosmoc++",
    ar = "cosmoar",
}

function cosmocc.gettoolname(cfg, tool)
	-- Check toolsetpaths first
	if cfg.toolsetpaths and cfg.toolsetpaths[cfg.toolset] and cfg.toolsetpaths[cfg.toolset][tool] then
		return cfg.toolsetpaths[cfg.toolset][tool]
	end

    return cosmocc.tools[tool]
end

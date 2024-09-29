--
-- cosmocc.lua
-- Cosmopolitan Libc toolset adapter for Premake
-- Copyright (c) 2024 Premake project
--

local p = premake
local gcc = p.tools.gcc

p.tools.cosmocc = table.merge(gcc, {})
local cosmocc = p.tools.cosmocc

cosmocc.tools = {
    cc = "cosmocc",
    cxx = "cosmoc++",
    ar = "ar",
}

-- cosmocc.arargs = "rcs"

function cosmocc.gettoolname(cfg, tool)
    return cosmocc.tools[tool]
end

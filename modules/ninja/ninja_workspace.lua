local p = premake
local ninja = p.modules.ninja

local tree = p.tree
local project = p.project

p.modules.ninja.wks = {}
local m = p.modules.ninja.wks

m.elements = function(wks)
    return {
        ninja.header,
    }
end

function m.generate(wks)
    p.utf8()
    p.callArray(m.elements, wks)
end
local p = premake

p.modules.raw = {}

local m = p.modules.raw
m.elements = {}

dofile("_preload.lua")
dofile("raw_action.lua")

return m

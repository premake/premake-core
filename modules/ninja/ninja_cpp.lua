local p = premake
local ninja = p.modules.ninja

local tree = p.tree
local project = p.project

p.modules.ninja.cpp = {}
local m = p.modules.ninja.cpp

m.elements = function(cfg)
    return {
        ninja.header,
        m.ccrules,
        m.cxxrules,
        m.resourcerules,
        m.linkrules,
        m.pchrules,
        m.copyrules,
        m.prebuildcommandsrule,
        m.prebuildmessagerule,
        m.prelinkcommandsrule,
        m.prelinkmessagerule,
        m.postbuildcommandsrule,
        m.postbuildmessagerule,
        m.customcommand,
        m.buildfiles,
        m.linkfiles,
        m.prebuildcommands,
        m.prebuildmessage,
        m.prelinkcommands,
        m.prelinkmessage,
        m.postbuildcommands,
        m.postbuildmessage,
        m.phonies,
    }
end

function m.generate(cfg)
    p.utf8()
    p.callArray(m.elements, cfg)
end

function m.ccrules(cfg)
    local toolset = ninja.gettoolset(cfg)
    local ccname = toolset.gettoolname(cfg, "cc")
    _p("rule cc")

    if toolset == p.tools.msc then
        _p("  command = %s $cflags /nologo /showIncludes -c /Tc$in /Fo$out", ccname)
        _p("  deps = msvc")
    else
        _p("  command = %s $cflags -c $in -o $out", ccname)
        _p("  deps = gcc")
    end
    
    _p("  description = Compiling C source $in")
    _p("  depfile = $out.d")

    _p("")
end

function m.cxxrules(cfg)
    local toolset = ninja.gettoolset(cfg)
    local cxxname = toolset.gettoolname(cfg, "cxx")
    _p("rule cxx")
    
    if toolset == p.tools.msc then
        _p("  command = %s $cxxflags /nologo /showIncludes -c /Tp$in /Fo$out", cxxname)
        _p("  deps = msvc")
    else
        _p("  command = %s $cxxflags -c $in -o $out", cxxname)
        _p("  deps = gcc")
    end

    _p("  description = Compiling C++ source $in")
    _p("  depfile = $out.d")

    _p("")
end

function m.resourcerules(cfg)
    local toolset = ninja.gettoolset(cfg)
    local rcname = toolset.gettoolname(cfg, "rc")

    _p("rule rc")
    
    if toolset == p.tools.msc then
        _p("  command = %s /nologo /fo$out $in $resflags", rcname)
    else
        _p("  command = %s -i $in -o $out $resflags", rcname)
    end
    
    _p("  description = Compiling resource $in")
    _p("")
end

function m.linkrules(cfg)
    local toolset = ninja.gettoolset(cfg)

    if toolset == p.tools.msc then
        if cfg.kind == p.STATICLIB then
            local arname = toolset.gettoolname(cfg, "ar")
            _p("rule ar")
            _p("  command = %s $in /nologo -OUT:$out", arname)
            _p("  description = Archiving static library $out")
            _p("")
        else
            local ldname = toolset.gettoolname(cfg, iif(cfg.language == "C", "cc", "cxx"))
            _p("rule link")
            _p("  command = %s $in $links /link $ldflags /nologo /out:$out", ldname)
            _p("  description = Linking target $out")
            _p("")
        end
    else
        if cfg.kind == p.STATICLIB then
            local arname = toolset.gettoolname(cfg, "ar")
            _p("rule ar")
            _p("  command = %s -rcs $out $in", arname)
            _p("  description = Archiving static library $out")
            _p("")
        else
            local ldname = toolset.gettoolname(cfg, iif(cfg.language == "C", "cc", "cxx"))
            local groups = iif(cfg.linkgroups == p.ON, { "-Wl,--start-group", "-Wl,--end-group" }, {"", ""})

            -- format the link command
            local commands = string.format("command = %s -o $out %s $in $links $ldflags %s", ldname, groups[1], groups[2]);
            
            -- remove any excess whitespace
            commands = commands:gsub("^%s*(.-)%s*$", "%1")
            commands = commands:gsub("%s+", " ")

            _p("rule link")
            _p("  %s", commands)
            _p("  description = Linking target $out")
            _p("")
        end
    end
end

function m.pchrules(cfg)
end

function m.copyrules(cfg)
end

function m.prebuildcommandsrule(cfg)
end

function m.prebuildmessagerule(cfg)
end

function m.prelinkcommandsrule(cfg)
end

function m.prelinkmessagerule(cfg)
end

function m.postbuildcommandsrule(cfg)
end

function m.postbuildmessagerule(cfg)
end

function m.customcommand(cfg)
end

function m.buildfiles(cfg)
end

function m.linkfiles(cfg)
end

function m.prebuildcommands(cfg)
end

function m.prebuildmessage(cfg)
end

function m.prelinkcommands(cfg)
end

function m.prelinkmessage(cfg)
end

function m.postbuildcommands(cfg)
end

function m.postbuildmessage(cfg)
end

function m.phonies(cfg)
end

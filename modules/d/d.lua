
--
-- Create a D namespace to isolate the additions
--
    premake.extensions.d = {}
    local project = premake5.project

    local d = premake.extensions.d
    d.support_url = "https://bitbucket.org/premakeext/d/wiki/Home"

    d.printf = function( msg, ... )
        printf( "[premake-d] " .. msg, ...)
    end


    d.printf( "Loading Premake D extension" )

    -- Extend the package path to include the directory containing this
    -- script so we can easily 'require' additional resources
    local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]; 
    package.path = this_dir .. "tools/?.lua;" .. this_dir .. "actions/?.lua;".. package.path
    d.printf( "Added D tools/actions directories to LUA_PATH: %s", package.path )

--
-- Register the D extension
--
    premake.D = "D"

    local lang = premake.fields["language"];
    if lang ~= nil and lang.allowed.D == nil then
        table.insert( lang.allowed, "D" );
    end

--
-- Provide information for the help output
--
    newoption
    {
        trigger     = "dc",
        value       = "VALUE",
        description = "Choose a D compiler",
        allowed = {
            { "dmd", "Digital Mars (dmd)" },
            { "gdc", "GNU GDC (gdc)" },
            { "ldc", "LLVM LDC (ldc2)" },
        }
    }

--
-- Add our valid actions/tools to the ipredefined action(s)
-- For each of the nominated allowed toolsets in the 'dc' options above,
-- we require a similarly named tools file in 'd/tools/<dc>.lua
--

    for k,v in pairs({"dmd", "gdc", "ldc"}) do
        require( v )
        d.printf( "Loaded D tool '%s.lua'", v )
    end

--
-- For each registered premake <action>, we can simply add a file to the
-- 'd/actions/' extension subdirectory named 'd/actions/<action>.lua' and the following
-- iteration will 'require' it into the system.  Hence we can patch any/all
-- pre-defined actions by adding a named file.  This eases development as
-- we don't need to cram make stuff in with VS stuff etc.
--
    for k,v in pairs({ "gmake" }) do
        require( v )
        d.printf( "Loaded D action '%s.lua'", v )
    end

--
-- Patch the project structure to allow the determination of project type
-- This is then used in the override of gmake.onproject() in the
-- extension files
--

    function project.isd(prj)
        return string.lower( prj.language ) == string.lower( premake.D )
    end

--
-- Patch the path table to provide knowledge of D file extenstions
--
    function path.isdfile(fname)
        return path.hasextension(fname, { ".d", ".di" })
    end


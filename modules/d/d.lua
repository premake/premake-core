
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
-- Create a D namespace to isolate the additions
--
premake.extensions.d = {}
local d = premake.extensions.d
local project = premake5.project

--
-- Add our valid actions/tools to the ipredefined action(s)
--

printf( "[AG] Current working directory is %s", os.getcwd() )

--
-- For each of the nominated allowed toolsets in the 'dc' options above,
-- we require a similarly named tools file in 'd/tools/<dc>.lua
--

local dc = premake.option.get( "dc" )
if dc ~= nil then
    for k,v in pairs(dc.allowed) do
        if os.isfile( "d/tools/" .. v[ 1 ] .. ".lua" ) then
            require( "d/tools/" .. v[ 1 ] )
        end
    end
end

--
-- For each registered premake <action>, we can simply add a file to the
-- 'd/actions/' extension subdirectory named 'd/actions/<action>.lua' and the following
-- iteration will 'require' it into the system.  Hence we can patch any/all
-- pre-defined actions by adding a named file.  This eases development as
-- we don't need to cram make stuff in with VS stuff etc.
--
for k,v in pairs(premake.action.list) do
    if os.isfile( "d/actions/" .. v.trigger .. ".lua" ) then
        require( "d/actions/" .. v.trigger )
    end
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


newaction
{
    trigger         = "raw",
    shortname       = "Raw output",
    description     = "Generate raw representation of Premake structures",

    valid_kinds     = { "ConsoleApp", "WindowedApp", "SharedLib", "StaticLib", "Makefile", "None", "Utility" },
    valid_languages = { "C", "C++" },
    valid_tools     = { cc = { "clang" } },

    onsolution = function(sln)
        require('raw')

        premake.generate(sln, ".raw", premake.raw.solution)
    end,
}

return function(cfg)
	return (_ACTION == "raw")
end

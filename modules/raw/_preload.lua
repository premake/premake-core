newaction
{
	trigger         = "raw",
	shortname       = "Raw output",
	description     = "Generate raw representation of Premake structures",

	onsolution = function(sln)
		require('raw')

		premake.generate(sln, ".raw", premake.raw.workspace)
	end,
}

return function(cfg)
	return (_ACTION == "raw")
end

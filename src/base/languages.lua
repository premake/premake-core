---
-- languages.lua
-- Language helpers.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
---

	local p = premake
	p.languages = {}

	function p.languages.isc(value)
		return value == "C";
	end

	function p.languages.iscpp(value)
		return value == "C++";
	end

	function p.languages.isdotnet(value)
		return value == "C#";
	end

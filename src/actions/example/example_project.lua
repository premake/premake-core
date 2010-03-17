-- An example project generator; see _example.lua for action description

-- 
-- The project generation function, attached to the action in _example.lua.
-- By now, premake.generate() has created the project file using the name
-- provided in _example.lua, and redirected input to this new file.
--

	function premake.example.project(prj)
		-- If necessary, set an explicit line ending sequence
		-- io.eol = '\r\n'
	
		-- Let's start with a header
		_p('-- An example project file')
		_p('Name: %s', prj.name)
		
	end

--
-- xcode_sections.lua
-- Functions to generate the different sections of an Xcode project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode

	function xcode.Header()
		_p('// !$*UTF8*$!')
		_p('{')
		_p('\tarchiveVersion = 1;')
		_p('\tclasses = {')
		_p('\t};')
		_p('\tobjectVersion = 45;')
		_p('\tobjects = {')
		_p('')
	end


	function xcode.Footer()
		_p(1,'};')
		_p('\trootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')
	end

--
-- modules/vstudio/tests/dotnet2005/test_nuget_framework_folders.lua
-- Validate parsing of framework versions from folder names for
-- Visual Studio 2010 and newer
-- Copyright (c) 2017 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_dn2005_nuget_framework_folders")
	local dn2005 = p.vstudio.dotnetbase


	function suite.net()
		test.isequal(dn2005.frameworkVersionForFolder("net451"), "4510000000")
		test.isequal(dn2005.frameworkVersionForFolder("net45"), "4500000000")
		test.isequal(dn2005.frameworkVersionForFolder("net20"), "2000000000")
		test.isequal(dn2005.frameworkVersionForFolder("net35"), "3500000000")
		test.isequal(dn2005.frameworkVersionForFolder("net"), "0000000000")
	end

	function suite.numeric()
		test.isequal(dn2005.frameworkVersionForFolder("10"), "1000000000")
		test.isequal(dn2005.frameworkVersionForFolder("11"), "1100000000")
		test.isequal(dn2005.frameworkVersionForFolder("20"), "2000000000")
		test.isequal(dn2005.frameworkVersionForFolder("45"), "4500000000")
	end

	function suite.numericWithDots()
		test.isequal(dn2005.frameworkVersionForFolder("1.0"), "1000000000")
		test.isequal(dn2005.frameworkVersionForFolder("1.1"), "1100000000")
		test.isequal(dn2005.frameworkVersionForFolder("2.0"), "2000000000")
		test.isequal(dn2005.frameworkVersionForFolder("4.5"), "4500000000")
	end

	function suite.invalid()
		test.isnil(dn2005.frameworkVersionForFolder("netstandard1.3"))
		test.isnil(dn2005.frameworkVersionForFolder("sl4"))
		test.isnil(dn2005.frameworkVersionForFolder("sl5"))
		test.isnil(dn2005.frameworkVersionForFolder("uap10"))
		test.isnil(dn2005.frameworkVersionForFolder("wp8"))
		test.isnil(dn2005.frameworkVersionForFolder("wp71"))
	end

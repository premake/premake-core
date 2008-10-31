--
-- tests/test_template.lua
-- Automated test suite for the templating system.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.template = { }

--
-- A test object.
--

	local obj = { }
	obj.name = "MyProject"
	

--
-- template.encode() tests
--

	function T.template.encode_SimpleString()
		t = "Hi there"
		test.isequal("io.write[=[Hi there]=]", premake.template.encode(t))
	end
	
	function T.template.encode_TrailingNewline()
		t = "Line 1\n"
		test.isequal("io.write[=[Line 1]=]io.write(eol)\n", premake.template.encode(t))
	end

	function T.template.encode_LeadingNewlines()
		t = "\nLine 1"
		test.isequal("io.write(eol)\nio.write[=[Line 1]=]", premake.template.encode(t))
	end
	
	function T.template.encode_InlineExpression()
		t = "Name is <%= this.name %>\nAnother Line"
		test.isequal("io.write[=[Name is ]=]io.write( this.name )io.write(eol)\nio.write[=[Another Line]=]", premake.template.encode(t))
	end

	function T.template.encode_InlineStatement()
		t = "Start\n  <% for i=1,10 do %> \n item\n <%end%> \nDone\n"
		test.isequal("io.write[=[Start]=]io.write(eol)\n for i=1,10 do \nio.write[=[ item]=]io.write(eol)\nend\nio.write[=[Done]=]io.write(eol)\n", premake.template.encode(t))
	end	

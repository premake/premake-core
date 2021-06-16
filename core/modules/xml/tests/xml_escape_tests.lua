local xml = require('xml')

local XmlEscapeTests = test.declare('XmlEscapeTests', 'xml')


function XmlEscapeTests.escape_escapesAmpersands()
	test.isEqual('x &amp; y', xml.escape('x & y'))
end


function XmlEscapeTests.escape_escapesAngleBrackets()
	test.isEqual('&lt;element&gt;', xml.escape('<element>'))
end


function XmlEscapeTests.escape_escapesDoubleQuotes()
	test.isEqual('the &quot;real&quot; thing', xml.escape('the "real" thing'))
end

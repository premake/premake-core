---
-- vs2010_rules_xml.lua
-- Generate a Visual Studio 201x custom rules XML file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	premake.vstudio.vs2010.rules.xml = {}

	local m = premake.vstudio.vs2010.rules.xml
	m.elements = {}

	local p = premake


---
-- Entry point; generate the root <ProjectSchemaDefinitions> element.
---

	m.elements.project = function(r)
		return {
			p.xmlUtf8,
			m.projectSchemaDefinitions,
			m.rule,
			m.ruleItem,
			m.fileExtension,
			m.contentType,
		}
	end

	function m.generate(r)
		p.callArray(m.elements.project, r)
		p.pop('</ProjectSchemaDefinitions>')
	end



---
-- Generate the main <Rule> element.
---

	m.elements.rule = function(r)
		return {
			m.dataSource,
			m.categories,
		}
	end

	function m.rule(r)
		p.push('<Rule')
		p.w('Name="%s"', r.name)
		p.w('PageTemplate="tool"')
		p.w('DisplayName="%s"', r.description or r.name)
		p.w('Order="200">')
		p.callArray(m.elements.rule, r)
		p.pop('</Rule>')
	end



---
-- Generate the list of categories.
---

	function m.categories(r)
		local categories = {
			[1] = { name="General" },
			[2] = { name="Command Line", subtype="CommandLine" },
		}
		p.push('<Rule.Categories>')
		for i = 1, #categories do
			m.category(categories[i])
		end
		p.pop('</Rule.Categories>')
	end


	function m.category(cat)
		local attribs = p.capture(function()
			p.push()
			p.w('Name="%s"', cat.name)
			if cat.subtype then
				p.w('Subtype="%s"', cat.subtype)
			end
			p.pop()
		end)

		p.push('<Category')
		p.outln(attribs .. '>')

		p.push('<Category.DisplayName>')
		p.w('<sys:String>%s</sys:String>', cat.name)
		p.pop('</Category.DisplayName>')

		p.pop('</Category>')
	end



---
-- Implementations of individual elements.
---

	function m.contentType(r)
		p.w('<ContentType')
		p.w('  Name="%s"', r.name)
		p.w('  DisplayName="%s"', r.name)
		p.w('  ItemType="%s" />', r.name)
	end



	function m.dataSource(r)
		p.push('<Rule.DataSource>')
		p.w('<DataSource')
		p.w('  Persistence="ProjectFile"')
		p.w('  ItemType="%s" />', r.name)
		p.pop('</Rule.DataSource>')
	end



	function m.fileExtension(r)
		p.w('<FileExtension')
		p.w('  Name="*.XYZ"')
		p.w('  ContentType="%s" />', r.name)
	end



	function m.ruleItem(r)
		p.w('<ItemType')
		p.w('  Name="%s"', r.name)
		p.w('  DisplayName="%s" />', r.name)
	end



	function m.projectSchemaDefinitions(r)
		p.push('<ProjectSchemaDefinitions xmlns="http://schemas.microsoft.com/build/2009/properties" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:sys="clr-namespace:System;assembly=mscorlib">')
	end


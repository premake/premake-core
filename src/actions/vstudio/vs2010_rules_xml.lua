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
			m.inputs,
			m.properties,
		}
	end

	function m.rule(r)
		p.push('<Rule')
		p.w('Name="%s"', r.name)
		p.w('PageTemplate="tool"')
		p.w('DisplayName="%s"', r.display or r.name)
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
-- Generate the list of property definitions.
---

	function m.properties(r)
		local defs = r.propertyDefinition
		for i = 1, #defs do
			local def = defs[i]
			if def.kind == "boolean" then
				m.boolProperty(def)
			elseif def.kind == "list" then
				m.stringListProperty(def)
			elseif type(def.values) == "table" then
				m.enumProperty(def)
			else
				m.stringProperty(def)
			end
		end
	end


	function m.baseProperty(def, close)
		p.w('Name="%s"', def.name)
		p.w('HelpContext="0"')
		p.w('DisplayName="%s"', def.display or def.name)
		p.w('Description="%s"%s', def.description or def.display or def.name, iif(close, ">", ""))
	end


	function m.boolProperty(def)
		p.push('<BoolProperty')
		m.baseProperty(def)
		if def.switch then
			p.w('Switch="%s" />', def.switch)
		end
		p.pop()
	end


	function m.enumProperty(def)
		p.push('<EnumProperty')
		m.baseProperty(def, true)

		local values = def.values
		local switches = def.switch or {}

		local keys = table.keys(def.values)
		table.sort(keys)

		for _, key in pairs(keys) do
			p.push('<EnumValue')
			p.w('Name="%d"', key)
			if switches[key] then
				p.w('DisplayName="%s"', values[key])
				p.w('Switch="%s" />', switches[key])
			else
				p.w('DisplayName="%s" />', values[key])
			end
			p.pop()
		end

		p.pop('</EnumProperty>')
	end


	function m.stringProperty(def)
		p.push('<StringProperty')
		m.baseProperty(def)
		p.w('Switch="[value]" />')
		p.pop()
	end


	function m.stringListProperty(def)
		p.push('<StringListProperty')
		m.baseProperty(def)
		if def.separator then
			p.w('Separator="%s"', def.separator)
		end
		p.w('Switch="[value]" />')
		p.pop()
	end



---
-- Implementations of individual elements.
---

	function m.contentType(r)
		p.push('<ContentType')
		p.w('Name="%s"', r.name)
		p.w('DisplayName="%s"', r.name)
		p.w('ItemType="%s" />', r.name)
		p.pop()
	end



	function m.dataSource(r)
		p.push('<Rule.DataSource>')
		p.push('<DataSource')
		p.w('Persistence="ProjectFile"')
		p.w('ItemType="%s" />', r.name)
		p.pop()
		p.pop('</Rule.DataSource>')
	end



	function m.fileExtension(r)
		p.push('<FileExtension')
		p.w('Name="*.XYZ"')
		p.w('ContentType="%s" />', r.name)
		p.pop()
	end



	function m.inputs(r)
		p.push('<StringListProperty')
		p.w('Name="Inputs"')
		p.w('Category="Command Line"')
		p.w('IsRequired="true"')
		p.w('Switch=" ">')

		p.push('<StringListProperty.DataSource>')
		p.push('<DataSource')
		p.w('Persistence="ProjectFile"')
		p.w('ItemType="%s"', r.name)
		p.w('SourceType="Item" />')
		p.pop()

		p.pop('</StringListProperty.DataSource>')
		p.pop('</StringListProperty>')
	end



	function m.ruleItem(r)
		p.push('<ItemType')
		p.w('Name="%s"', r.name)
		p.w('DisplayName="%s" />', r.name)
		p.pop()
	end



	function m.projectSchemaDefinitions(r)
		p.push('<ProjectSchemaDefinitions xmlns="http://schemas.microsoft.com/build/2009/properties" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:sys="clr-namespace:System;assembly=mscorlib">')
	end


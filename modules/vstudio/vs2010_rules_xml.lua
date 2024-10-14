---
-- vs2010_rules_xml.lua
-- Generate a Visual Studio 201x custom rules XML file.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.vs2010.rules.xml = {}

	local m = p.vstudio.vs2010.rules.xml
	m.elements = {}


---
-- Entry point; generate the root <ProjectSchemaDefinitions> element.
---

	m.elements.project = function(r)
		return {
			m.projectSchemaDefinitions,
			m.rule,
			m.ruleItem,
			m.fileExtension,
			m.contentType,
		}
	end

	function m.generate(r)
		p.xmlUtf8()
		p.callArray(m.elements.project, r)
		p.out('</ProjectSchemaDefinitions>')
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
			m.commandLineTemplate,
			m.beforeTargets,
			m.afterTargets,
			m.outputs,
			m.executionDescription,
			m.additionalDependencies,
			m.additionalOptions,
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
		}
		local propCategory = {}
		local defs = r.propertydefinition
		for i = 1, #defs do
			local def = defs[i]
			local cat = def.category
			if cat then
				if type(cat) == "string" and cat ~= "Command Line" and cat ~= "General" then
					if not propCategory[cat] then
						table.insert(categories, { name=cat })
						propCategory[cat] = true
					end
				else
					def.category = nil
				end
			end
		end
		table.insert(categories, { name="Command Line", subtype="CommandLine" })
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
		local defs = r.propertydefinition
		for i = 1, #defs do
			local def = defs[i]
			if def.kind == "boolean" then
				m.boolProperty(def)
			elseif def.kind == "list" then
				m.stringListProperty(def)
			elseif type(def.values) == "table" then
				m.enumProperty(def)
			elseif def.kind and def.kind:startswith("list:") then
				m.stringListProperty(def)
			else
				m.stringProperty(def)
			end
		end
	end


	function m.baseProperty(def, suffix)
		local c = p.capture(function ()
			p.w('Name="%s"', def.name)
			p.w('HelpContext="0"')
			p.w('DisplayName="%s"', def.display or def.name)
			if def.description then
				p.w('Description="%s"', def.description)
			end
			if def.category then
				p.w('Category="%s"', def.category)
			end
		end)
		if suffix then
			c = c .. suffix
		end
		p.outln(c)
	end


	function m.boolProperty(def)
		p.push('<BoolProperty')
		m.baseProperty(def)
		if def.switch then
			p.w('Switch="%s"', def.switch)
		end
		p.w('/>')
		p.pop()
	end


	function m.enumProperty(def)
		p.push('<EnumProperty')
		m.baseProperty(def, '>')

		local values = def.values
		local switches = def.switch or {}

		local keys = table.keys(def.values)
		table.sort(keys)

		for _, key in pairs(keys) do
			p.push('<EnumValue')
			p.w('Name="%d"', key)
			if switches[key] then
				p.w('DisplayName="%s"', values[key])
				if switches[key] then
					p.w('Switch="%s"', switches[key])
				end
			else
				p.w('DisplayName="%s"', values[key])
			end
			p.w('/>')
			p.pop()
		end

		p.pop('</EnumProperty>')
	end


	function m.stringProperty(def)
		p.push('<StringProperty')
		m.baseProperty(def)
		if def.switch then
			p.w('Switch="%s"', def.switch)
		end
		p.w('/>')
		p.pop()
	end


	function m.stringListProperty(def)
		p.push('<StringListProperty')
		m.baseProperty(def)
		if def.separator then
			p.w('Separator="%s"', def.separator)
		end
		if def.switch then
			p.w('Switch="%s"', def.switch)
		end
		p.w('/>')
		p.pop()
	end



---
-- Implementations of individual elements.
---

	function m.additionalDependencies(r)
		p.push('<StringListProperty')
		p.w('Name="AdditionalDependencies"')
		p.w('DisplayName="Additional Dependencies"')
		p.w('IncludeInCommandLine="False"')
		p.w('Visible="false" />')
		p.pop()
	end



	function m.additionalOptions(r)
		p.push('<StringProperty')
		p.w('Subtype="AdditionalOptions"')
		p.w('Name="AdditionalOptions"')
		p.w('Category="Command Line">')
		p.push('<StringProperty.DisplayName>')
		p.w('<sys:String>Additional Options</sys:String>')
		p.pop('</StringProperty.DisplayName>')
		p.push('<StringProperty.Description>')
		p.w('<sys:String>Additional Options</sys:String>')
		p.pop('</StringProperty.Description>')
		p.pop('</StringProperty>')
	end



	function m.afterTargets(r)
		p.push('<DynamicEnumProperty')
		p.w('Name="%sAfterTargets"', r.name)
		p.w('Category="General"')
		p.w('EnumProvider="Targets"')
		p.w('IncludeInCommandLine="False">')

		p.push('<DynamicEnumProperty.DisplayName>')
		p.w('<sys:String>Execute After</sys:String>')
		p.pop('</DynamicEnumProperty.DisplayName>')

		p.push('<DynamicEnumProperty.Description>')
		p.w('<sys:String>Specifies the targets for the build customization to run after.</sys:String>')
		p.pop('</DynamicEnumProperty.Description>')

		p.push('<DynamicEnumProperty.ProviderSettings>')
		p.push('<NameValuePair')
		p.w('Name="Exclude"')
		p.w('Value="^%sAfterTargets|^Compute" />', r.name)
		p.pop()
		p.pop('</DynamicEnumProperty.ProviderSettings>')

		p.push('<DynamicEnumProperty.DataSource>')
		p.push('<DataSource')
		p.w('Persistence="ProjectFile"')
		p.w('ItemType=""')
		p.w('HasConfigurationCondition="true" />')
		p.pop()
		p.pop('</DynamicEnumProperty.DataSource>')

		p.pop('</DynamicEnumProperty>')
	end



	function m.beforeTargets(r)
		p.push('<DynamicEnumProperty')
		p.w('Name="%sBeforeTargets"', r.name)
		p.w('Category="General"')
		p.w('EnumProvider="Targets"')
		p.w('IncludeInCommandLine="False">')

		p.push('<DynamicEnumProperty.DisplayName>')
		p.w('<sys:String>Execute Before</sys:String>')
		p.pop('</DynamicEnumProperty.DisplayName>')

		p.push('<DynamicEnumProperty.Description>')
		p.w('<sys:String>Specifies the targets for the build customization to run before.</sys:String>')
		p.pop('</DynamicEnumProperty.Description>')

		p.push('<DynamicEnumProperty.ProviderSettings>')
		p.push('<NameValuePair')
		p.w('Name="Exclude"')
		p.w('Value="^%sBeforeTargets|^Compute" />', r.name)
		p.pop()
		p.pop('</DynamicEnumProperty.ProviderSettings>')

		p.push('<DynamicEnumProperty.DataSource>')
		p.push('<DataSource')
		p.w('Persistence="ProjectFile"')
		p.w('HasConfigurationCondition="true" />')
		p.pop()
		p.pop('</DynamicEnumProperty.DataSource>')

		p.pop('</DynamicEnumProperty>')
	end



	function m.commandLineTemplate(r)
		p.push('<StringProperty')
		p.w('Name="CommandLineTemplate"')
		p.w('DisplayName="Command Line"')
		p.w('Visible="False"')
		p.w('IncludeInCommandLine="False" />')
		p.pop()
	end



	function m.contentType(r)
		p.push('<ContentType')
		p.w('Name="%s"', r.name)
		p.w('DisplayName="%s"', r.display or r.name)
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



	function m.executionDescription(r)
		p.push('<StringProperty')
		p.w('Name="ExecutionDescription"')
		p.w('DisplayName="Execution Description"')
		p.w('Visible="False"')
		p.w('IncludeInCommandLine="False" />')
		p.pop()
	end



	function m.fileExtension(r)
		for _, v in ipairs(r.fileextension) do
			p.push('<FileExtension')
			p.w('Name="*%s"', v)
			p.w('ContentType="%s" />', r.name)
			p.pop()
		end
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



	function m.outputs(r)
		p.push('<StringListProperty')
		p.w('Name="Outputs"')
		p.w('DisplayName="Outputs"')
		p.w('Visible="False"')
		p.w('IncludeInCommandLine="False" />')
		p.pop()
	end



	function m.ruleItem(r)
		p.push('<ItemType')
		p.w('Name="%s"', r.name)
		p.w('DisplayName="%s" />', r.display or r.name)
		p.pop()
	end



	function m.projectSchemaDefinitions(r)
		p.push('<ProjectSchemaDefinitions xmlns="http://schemas.microsoft.com/build/2009/properties" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:sys="clr-namespace:System;assembly=mscorlib">')
	end


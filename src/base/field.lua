---
-- base/field.lua
--
-- Fields hold a particular bit of information about a configuration, such
-- as the language of a project or the list of files it uses. Each field has
-- a particular data "kind", which describes the structure of the information
-- it holds, such a simple string, or a list of paths.
--
-- The field.* functions here manage the definition of these fields, and the
-- accessor functions required to get, set, remove, and merge their values.
--
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	premake.field = {}
	local field = premake.field


-- Lists to hold all of the registered fields and data kinds

	field._list = {}
	field._kinds = {}

	-- For historical reasons
	premake.fields = field._list



---
-- Register a new field.
--
-- @param f
--    A table describing the new field, with these keys:
--     name     A unique string name for the field, to be used to identify
--              the field in future operations.
--     kind     The kind of values that can be stored into this field. Kinds
--              can be chained together to create more complex types, such as
--              "list:string".
--
--    In addition, any custom keys set on the field description will be
--    maintained.
--
-- @return
--    A populated field object. Or nil and an error message if the field could
--    not be registered.
---

	function field.new(f)
		field._list[f.name] = f
		return f
	end



---
-- Fetch a field description by name.
---

	function field.get(name)
		return field._list[name]
	end

---
-- container.lua
-- Implementation of configuration containers.
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	local p = premake
	p.containerClass = {}
	p.container = {}

	local container = p.container



-- The master list of registered container classes

	container._classes = {}



---
-- The metatable allows container functions to be called with the ":" syntax,
-- and also allows API field values to be get and set as if they were direct
-- properties.
--
-- TODO: I think I'd like to get away from treating the fields as direct
-- properties on the containers (fine on the baked contexts later) and require
-- explicit fetch() and store() calls instead.
---

	p.containerClass.__index = p.containerClass

	p.container.__index = function(c, key)
		local f = p.field.get(key)
		if f then
			return p.configset.fetch(c, f)
		else
			return p.container[key]
		end
	end


	p.container.__newindex = function(c, key, value)
		local f = p.field.get(key)
		if f then
			local status, err = p.configset.store(c, f, value)
			if err then
				error(err, 2)
			end
		else
			rawset(c, key, value)
			return value
		end
	end



---
-- A container class holds and operates on the metadata about a particular
-- type of container, including its name, parent container, and any child
-- containers. The container class is responsible for creating new instances
-- of its kind of containers.
--
-- @param def
--    A table containing metadata about the container class being created.
--    Supported keys are:
--
--     name (required)
--       The name of the new container class (e.g. "solution").
--     parent (optional)
--       The name of the parent container class (e.g. "solution").
--     init (optional)
--       An initializer function to call for new instances of this class.
--       Should accept the new instance object as its only argument.
--
--    Other keys are allowed and will be left intact.
--
-- @return
--    A new container class object if successful, else nil and an
--    error message.
---

	function p.containerClass.define(def)
		-- If the class has no special properties, allow it to be set using
		-- just the class name instead of the whole key-value list.

		if type(def) == "string" then
			def = { name = def }
		end

		-- Sanity check my inputs

		if not def.name then
			return nil, "name is required"
		end

		if container._classes[def.name] then
			return nil, "container class name already in use"
		end

		if def.parent and not container._classes[def.parent] then
			return nil, "parent class does not exist"
		end

		-- Looks good, set myself up and add to master list

		def._children = {}
		def._listKey = def.name:plural()
		setmetatable(def, p.containerClass)
		container._classes[def.name] = def

		-- Wire myself to my parent class

		def.parent = container._classes[def.parent]
		if def.parent then
			table.insert(def.parent._children, def)
		end

		return def
	end



---
-- Enumerate the child container class of a given class.
---

	function p.containerClass:eachChildClass()
		local children = self._children
		local i = 0
		return function ()
			i = i + 1
			if i <= #children then
				return children[i]
			end
		end
	end



---
-- Retrieve a container class by name.
--
-- @param name
--    The class name.
-- @return
--    The corresponding container class if found, nil otherwise.
---

	function p.containerClass.get(name)
		return container._classes[name]
	end



---
-- Create a new instance of a container class.
--
-- @param name
--    The name for the container instance.
-- @return
--    A new instance of the container class.
---

	function p.containerClass:new(name, parent)
		local c = p.configset.new(parent)
		setmetatable(c, p.container)

		c.class = self
		c.name = name
		c.script = _SCRIPT
		c.basedir = os.getcwd()
		c.filename = name

		if type(self.init) == "function" then
			self.init(c)
		end

		return c
	end



---
-- Create a new child container of the given class, with the specified name.
--
-- @param cc
--    The class of child container to be fetched.
-- @param key
--    A string key or array index for the container.
-- @param parent
--    The parent container instance.
-- @return
--    The child container instance.
---

	function container:createChild(cc, key, parent)
		self[cc._listKey] = self[cc._listKey] or {}
		local list = self[cc._listKey]

		local child = cc:new(key, parent)
		child[parent.class.name] = parent  -- i.e. child.solution = sln

		table.insert(list, child)
		list[key] = child
		return child
	end



---
-- Return an iterator for the child containers of a particular class.
--
-- @param cc
--    The class of child container to be enumerated.
---

	function container:eachChild(cc)
		local children = self[cc._listKey] or {}
		local i = 0
		return function ()
			i = i + 1
			if i <= #children then
				return children[i]
			end
		end
	end



---
-- Fetch the child container with the given container class and instance name.
--
-- @param cc
--    The class of child container to be fetched.
-- @param key
--    A string key or array index for the container.
-- @return
--    The child container instance.
---

	function container:fetchChild(cc, key)
		self[cc._listKey] = self[cc._listKey] or {}
		return self[cc._listKey][key]
	end

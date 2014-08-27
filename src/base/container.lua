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
-- containers. The container class is responsible for create new instances
-- of its kind of containers.
--
-- @param def
--    A table containing metadata about the container class being created.
--    Supported keys are:
--
--     name (required)
--       The name of the new container class (e.g. "solution").
--     init (optional)
--       An initializer function to call for new instances of this class.
--       Should accept the new instance object as its only argument.
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

		-- Fill in some calculated properties

		def.parent = container._classes[def.parent]
		def.listKey = def.name:plural()

		-- Finish: add to master list, enable calling with ":" syntax

		container._classes[def.name] = def
		setmetatable(def, p.containerClass)
		return def
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

		return c
	end



---
-- Return an iterator for the child containers of a particular class.
--
-- @param cc
--    The class of child container to be enumerated.
---

	function container:eachContainer(cc)
		local children = self[cc.listKey] or {}
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
-- If it doesn't exist, a new container is created.
--
-- @param cc
--    The class of child container to be fetched.
-- @param key
--    A string key or array index for the container. If a string key is
--    provided, the container will be created if it doesn't exist. If an
--    array index is provided, nil will be returned if it does not exist.
-- @return
--    The child container instance.
---

	function container:fetchContainer(cc, key)
		self[cc.listKey] = self[cc.listKey] or {}
		local children = self[cc.listKey]
		local c = children[key]

		if not c and type(key) == "string" then
			c = cc:new(key, parent)
			table.insert(children, c)
			children[key] = c
		end

		return c
	end

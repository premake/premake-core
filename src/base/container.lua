---
-- container.lua
-- Implementation of configuration containers.
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	local p = premake
	p.container = {}

	local container = p.container



---
-- Keep a master dictionary of container class, so they can be easily looked
-- up by name (technically you could look at premake["name"] but that is just
-- a coding convention and I don't want to count on it)
---

	container.classes = {}



---
-- Define a new class of containers.
--
-- @param name
--    The name of the new container class. Used wherever the class needs to
--    be shown to the end user in a readable way.
-- @param parent (optional)
--    If this class of container is intended to be contained within another,
--    the containing class object.
-- @return
--    If successful, the new class descriptor object (a table). Otherwise,
--    returns nil and an error message.
---

	function container.newClass(name, parent)
		local class = p.configset.new(parent)
		class.name = name
		class.pluralName = name:plural()
		class.containedClasses = {}

		if parent then
			table.insert(parent.containedClasses, class)
		end

		container.classes[name] = class
		return class
	end



---
-- Create a new instance of a configuration container. This is just the
-- generic base implementation, each container class will define their
-- own version.
--
-- @param parent
--    The class of container being instantiated.
-- @param name
--    The name for the new container instance.
-- @return
--    A new container instance.
---

	function container.new(class, name)
		local self = p.configset.new()
		setmetatable(self, p.configset.metatable(self))

		self.class = class
		self.name = name
		self.script = _SCRIPT
		self.basedir = os.getcwd()

		for childClass in container.eachChildClass(class) do
			self[childClass.pluralName] = {}
		end

		return self
	end



---
-- Add a new child to an existing container instance.
--
-- @param self
--    The container instance to hold the child.
-- @param child
--    The child container instance.
---

	function container.addChild(self, child)
		local children = self[child.class.pluralName]
		table.insert(children, child)
		children[child.name] = child

		child.parent = self
		child[self.class.name] = self
	end



---
-- Enumerate all of the registered child classes of a specific container class.
--
-- @param class
--    The container class to be enumerated.
-- @return
--    An iterator function for the container's child classes.
---

	function container.eachChildClass(class)
		local children = class.containedClasses
		local i = 0
		return function ()
			i = i + 1
			if i <= #children then
				return children[i]
			end
		end
	end



---
-- Enumerate all of the registered child instances of a specific container.
--
-- @param self
--    The container to be queried.
-- @param class
--    The class of child containers to be enumerated.
-- @return
--    An iterator function for the container's child classes.
---

	function container.eachChild(self, class)
		local children = self[class.pluralName]
		local i = 0
		return function ()
			i = i + 1
			if i <= #children then
				return children[i]
			end
		end
	end



---
-- Retrieve the child container with the specified class and name.
--
-- @param self
--    The container instance to query.
-- @param class
--    The class of the child container to be fetched.
-- @param name
--    The name of the child container to be fetched.
-- @return
--    The child instance if it exists, nil otherwise.
---

	function container.getChild(self, class, name)
		local children = self[class.pluralName]
		return children[name]
	end



---
-- Retrieve a container class object.
--
-- @param name
--    The name of the container class to retrieve.
-- @return
--    The container class object if it exists, nil otherwise.
---

	function container.getClass(name)
		return container.classes[name]
	end


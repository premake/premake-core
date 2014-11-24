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
		self.filename = name
		self.script = _SCRIPT
		self.basedir = os.getcwd()
		self.external = false

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
-- Process the contents of a container, which were populated by the project
-- script, in preparation for doing work on the results, such as exporting
-- project files.
---

	function container.bake(self)
		if self._isBaked then
			return self
		end
		self._isBaked = true

		local ctx = p.context.new(self)

		for key, value in pairs(self) do
			ctx[key] = value
		end

		local parent = self.parent
		ctx[parent.class.name] = parent

		for class in container.eachChildClass(self.class) do
			for child in container.eachChild(self, class) do
				child.parent = ctx
				child[self.class.name] = ctx
			end
		end

		if type(self.class.bake) == "function" then
			self.class.bake(ctx)
		end

		return ctx
	end


	function container.bakeChildren(self)
		for class in container.eachChildClass(self.class) do
			local children = self[class.pluralName]
			for i = 1, #children do
				local ctx = container.bake(children[i])
				children[i] = ctx
				children[ctx.name] = ctx
			end
		end
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



---
-- Return true if a container class is or inherits from the
-- specified class.
--
-- @param class
--    The container class to be tested.
-- @param scope
--    The name of the class to be checked against. If the container
--    class matches this scope (i.e. class is a project and the
--    scope is "project"), or if it is a parent object of it (i.e.
--    class is a solution and scope is "project"), then returns
--    true.
---

	function container.classIsA(class, scope)
		while class do
			if class.name == scope then
				return true
			end
			class = class.parent
		end
		return false
	end



---
-- Call out to the container validation to make sure everything
-- is as it should be before handing off to the actions.
---

	function container.validate(self)
		if type(self.class.validate) == "function" then
			self.class.validate(self)
		end
	end


	function container.validateChildren(self)
		for class in container.eachChildClass(self.class) do
			local children = self[class.pluralName]
			for i = 1, #children do
				container.validate(children[i])
			end
		end
	end

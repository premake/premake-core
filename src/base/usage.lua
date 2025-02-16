---
-- usage.lua
-- Premake usage object API
-- Author Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
---

	local p = premake
	p.usage = p.api.container("usage", p.project, { "config" })

	local usage = p.usage

    p.usage.PUBLIC = "PUBLIC"
    p.usage.PRIVATE = "PRIVATE"
    p.usage.INTERFACE = "INTERFACE"

---
-- Create a new usage container instance.
--
-- @param name
--    The name of the usage container.
-- @return
--    The new usage container.
---

    function usage.new(name)
        local use = p.container.new(usage, name)
        use["filename"] = nil
        use["basedir"] = nil
        use.project = p.api.scope.project
        return use
    end


---
-- Check if the usage has a magic name (PUBLIC, PRIVATE, INTERFACE)
--
-- @param self
--    The usage object.
-- @return
--    True if the usage is a special usage.
    function usage.isSpecial(self)
        return self.name == usage.PUBLIC or self.name == usage.PRIVATE or self.name == usage.INTERFACE
    end

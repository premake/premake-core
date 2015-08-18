---
-- group.lua
-- A psuedo-configuration container to represent project groups.
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	local p = premake
	p.group = p.api.container("group", p.workspace)
	local group = p.group


---
-- Bit of a hack: prevent groups from holding any configuration data.
---

	group.placeholder = true



	function group.new(name)
		return p.container.new(group, name)
	end

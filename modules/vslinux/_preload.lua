--
-- Name:        vslinux/_preload.lua
-- Purpose:     Define the Linux APIs.
-- Author:      Emilio López
-- Copyright:   (c) 2013-2022 Manu Evans and the Premake project
--

	local p = premake
	local api = p.api

--
-- Register the Linux extension
--

	api.addAllowed("system", p.LINUX)
	api.addAllowed("architecture", { "x86", "x64", "arm", "arm64", "aarch64" })
	api.addAllowed("toolchainversion", { "remote", "wsl", "wsl2" })
	
	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { "linux", "Linux" })
	end

	-- add system tags for linux.
	os.systemTags[p.LINUX] = { "linux", "posix" }

--
-- Register Linux properties
--

	-- Directory in the remote machine where our files will be copied
	api.register {
		name = "remoterootdir",
		scope = "config",
		kind = "string",
	}
	
	-- Relative per-project directory. Set to empty for the entire project to be copied as is
	-- Should default to empty really for the more seamless experience
	api.register {
		name = "remoteprojectrelativedir",
		scope = "config",
		kind = "string",
	}
	
	api.register {
		name = "remotemachine",
		scope = "config",
		kind = "string",
	}

	return function(cfg)
		return (cfg.system == p.LINUX)
	end

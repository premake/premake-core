-- Name: nvhpc/_preload.lua

	table.insert(premake.option.get("cc").allowed, { "nvhpc", "Nvidia HPC (nvc/nvc++)" })


	return function (cfg)
		return (cfg.toolset == "nvhpc")
	end

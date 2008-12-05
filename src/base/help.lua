--
-- help.lua
-- User help, displayed on /help option.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	function premake.showhelp()
	
		-- sort the lists of actions and options into alphabetical order
		actions = { }
		for name,_ in pairs(premake.actions) do table.insert(actions, name) end
		table.sort(actions)
		
		options = { }
		for name,_ in pairs(premake.options) do table.insert(options, name) end
		table.sort(options)
		
		
		-- display the basic usage
		printf("Premake %s, a build script generator", _PREMAKE_VERSION)
		printf(_PREMAKE_COPYRIGHT)
		printf("%s %s", _VERSION, _COPYRIGHT)
		printf("")
		printf("Usage: premake4 [options] action [arguments]")
		printf("")

		
		-- display all options
		printf("OPTIONS")
		printf("")
		for _,name in ipairs(options) do
			local opt = premake.options[name]
			local trigger = opt.trigger
			local description = opt.description
			
			if (opt.value) then trigger = trigger .. "=" .. opt.value end
			if (opt.allowed) then description = description .. "; one of:" end
			
			printf(" --%-15s %s", trigger, description) 
			if (opt.allowed) then
				table.sort(opt.allowed, function(a,b) return a[1] < b[1] end)
				for _, value in ipairs(opt.allowed) do
					printf("     %-14s %s", value[1], value[2])
				end
			end
			printf("")
		end

		-- display all actions
		printf("ACTIONS")
		printf("")
		for _,name in ipairs(actions) do
			printf(" %-17s %s", name, premake.actions[name].description)
		end
		printf("")


		-- see more
		printf("For additional information, see http://industriousone.com/premake")
		
	end



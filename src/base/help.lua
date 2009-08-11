--
-- help.lua
-- User help, displayed on /help option.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	function premake.showhelp()
	
		-- sort the lists of actions and options into alphabetical order
--		actions = { }
--		for action in premake.action.each() do
--			table.insert(actions, action.trigger)
--		end
--		table.sort(actions)
		
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
				for _, value in ipairs(opt.allowed) do
					printf("     %-14s %s", value[1], value[2])
				end
			end
			printf("")
		end

		-- display all actions
		printf("ACTIONS")
		printf("")
--		for _, name in ipairs(actions) do
		for action in premake.action.each() do
			printf(" %-17s %s", action.trigger, action.description)
		end
		printf("")


		-- see more
		printf("For additional information, see http://industriousone.com/premake")
		
	end



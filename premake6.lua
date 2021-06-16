---
-- Premake Next build configuration script
-- Use this script to configure the project with Premake6.
---

register('testing')

workspace('Premake', function ()
	configurations { 'Debug', 'Release' }

	project('Premake', function ()

		files {
			'core/host/src/**.h',
			'core/host/src/**.c',
			'core/host/src/**.lua',
			'core/contrib/lua/src/**.h',
			'core/contrib/lua/src/**.c',
			'core/modules/**.lua',
			'modules/**.lua'
		}

		removeFiles {
			'core/contrib/lua/src/lua.c',
			'core/contrib/lua/src/luac.c'
		}

		includeDirs {
			'core/host/include',
			'core/contrib'
		}

		when({ 'configurations:Debug' }, function ()
			defines '_DEBUG'
		end)

		when({ 'configurations:Release' }, function ()
			defines 'NDEBUG'
		end)

		when({ 'action:vstudio' }, function ()
			defines {
				'_CRT_SECURE_NO_DEPRECATE',
				'_CRT_SECURE_NO_WARNINGS',
				'_CRT_NONSTDC_NO_WARNINGS'
			}
		end)
	end)
end)

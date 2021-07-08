---
title: What is Premake?
---

## Projects as Code

Premake is a [command line application](https://en.wikipedia.org/wiki/Command-line_interface) which helps software developers author and manage the build files for their projects. Rather than hand authoring makefiles or manually adjusting settings in an IDE, Premake allows developers to describe their project in code, and then generate the appropriate workspaces, projects, makefiles, etc. for multiple platforms and toolsets automatically.

```lua title="A sample Premake script"
workspace('MyWorkspace', function ()
   configurations { 'Debug', 'Release' }

	project('MyProject', function ()
		files { '**.h', '**.cpp' }

		when({ 'configurations:Debug' }, function ()
			defines { 'DEBUG' }
		end)

		when({ 'configurations:Release' }, function ()
			defines { 'NDEBUG' }
		end)
	end)
end)
```

Using Premake, you can make a change once in your Premake script and then quickly regenerate your workspaces, projects, makefiles, etc. to your builds and team in sync. This is especially useful for large or multiplatform projects, but also streamlines development of even simple projects and teams. See the [Showcase](/community/showcase) for examples of organizations and projects using Premake.

---
title: "Community Update #6"
tags: [community-updates]
authors: starkos
---

### Enter the Exporters

The focus for this cycle was getting an exporter—I settled on Visual Studio—up and running and able to generate a basic, mostly hardcoded workspace and project. More details below, but TL;DR:

- All of the core systems are now in play, with the exception of toolsets and token expansion (more on those below)
- The **workspace**, **project**, **location**, and **filename** scripting APIs are implemented, as well as the ability to declare conditional configuration blocks
- A very rudimentary Visual Studio exporter is now in place, with the ability to generate mostly hardcoded C/C++ solutions and projects at the specified locations and filenames

### What's Next for Next

For those of you who are more interested in "is it done yet?" than "what's new?", here's my current thinking on what comes next:

- Decide if/how/when/where these improvements get merged (or not) with Premake5. I have some thoughts of course, and will be opening an RFC on the issue tracker shortly to gather feedback. I'l announce it on [@premakeapp](https://twitter.com/premakeapp) when I do.
- Get build configurations & files online—be able to generate simple Visual Studio C/C++ projects with no extra switches or dependencies
- Get Make and Xcode up to same level as Visual Studio—going to be some rewriting here as that code has seen a lot of wear and tear, and needs to be brought up to the latest code conventions
- Decide on and build out the new solution for toolset adapters—I'll open an RFC on the issue tracker for this as well
- Add **kind, links,** and the most important switches (e.g. **includedirs, symbols, optimize**)—be able to support the most common C/C++ builds

Somewhere in there I should also backfill the documentation so people know what's working. All of this is subject to change and peer pressure, feedback welcome.

{/* truncate */}

### What's New

I'm doing my best to keep [an inventory of the major changes here](https://github.com/starkos/premake-next/blob/master/docs/Changes-Since-v5.md); let me know if you spot anything missing (and thanks to those who have already).

#### Scoping is now explicit

Premake4/5's scoping rules have always been a big gotcha. Tough for newcomers, easy to break even for experienced users, and very difficult to debug. I'm proposing that scoping be made explicit using function callbacks. Here's what a simple Hello World script might look with the new approach (apologies again for the images; if OpenCollective's editor supports code blocks I haven't been able to find them yet).

```lua
workspace('HelloWorld', function ()
	configurations { 'Debug', 'Release' }

	project('HelloWorld', function ()
		kind 'ConsoleApplication'
		files { '**.h', '**.cpp' }

		when({ configurations='Debug' }, function ()
			defines { 'DEBUG' }
			symbols 'On'
		end)

		when({ configurations='Release' }, function ()
			defines { 'NDEBUG' }
			optimize 'On'
		end)
	end)
end)
```

_(Keep in mind, only **workspace, project, location,** and **filename** are implemented so far, the rest will be coming online ASAP. The name **when()** is a proposal, feedback welcome.)_

Under the hood, the provided configuration functions are called immediately. Under the hood, that workspace() helper looks like:

```lua
function workspace(name, fn)
	workspaces(name)
	when({ workspaces = name }, function ()
		baseDir(_SCRIPT_DIR)
		fn()
	end)
end)
```

…so things still work the same as in Premake5, but scopes are now clearly explicit, and the indentation actually makes real sense (and gets syntax-aware editor support.

The syntax is, unfortunately, noisy. Down the road I wouldn't be opposed to tweaking Premake's embedded Lua runtime to provide a simpler syntax.

#### Exporters are no longer version specific

The command to export a project for Visual Studio now looks like this:

```bash
# target the latest version of Visual Studio we support
premake6 vstudio

# target a specific version
premake6 vstudio=2017
```

As anyone working on the Visual Studio or Xcode exporters is well aware, tool vendors are no longer waiting for the next major release to add features and change project formats. While more work is needed, the new command line syntax at least opens up the possibility of doing something like…

```bash
premake6 vstudio=14.0.25431.01
```

…which will allow us to support people who need to target a specific build of one of these tools.

#### Container hierarchy is now more flexible

In Premake4+, projects were required to be declared within one and only one workspace; this is now loosened up. The earlier Hello, World example could also be written like:

```lua
workspaces { 'HelloWorld' }
projects { 'HelloWorld' }

when({ 'workspaces:HelloWorld' }, function ()
	projects { 'HelloWorld' }
end)
```

Projects can be shared between workspaces, or even be completely standalone, if the target toolset supports it.

### What's next

I covered this above, but an RFC to coordinate v5 vs. vNext development is currently next on my to-do list.

These are big changes and I welcome questions, suggestions, and concerns. Everything is up for discussion, from the feature set, to the coding style. You can message or DM me at [@premakeapp](https://twitter.com/premakeapp), email at **starkos@industriousone.com**, or open an issue on [the premake-next GitHub project](https://github.com/starkos/premake-next).

### Thanks to our supporters! 🎉

Many thanks to my co-maintainer [@samsinsane](https://github.com/samsinsane), who has been doing a stellar job of keeping the shop running while I've been distracted with the new code, and to [@nickclark2016](https://github.com/nickclark2016), [@noresources](https://github.com/noresources), [@nickgravelyn](https://github.com/nickgravelyn), [@Jarod42](https://github.com/Jarod42), and [@cos-public](https://github.com/cos-public) for helping out with issues and new pull requests—very much appreciated!

And another big shout out to **[CitizenFX Collective](https://opencollective.com/_fivem#section-contributions)** for their continued strong financial support—as well as [all of our monthly backers](https://opencollective.com/premake#section-contributors!

Doing my best to get this new version fully up to speed ASAP for all of you.

~st.

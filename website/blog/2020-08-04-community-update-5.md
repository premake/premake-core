---
title: "Community Update #5"
tags: [community-updates]
author: starkos
author_url: https://github.com/starkos
author_image_url: https://avatars.githubusercontent.com/u/249247?v=4
author_title: Premake Admin & Developer
---

### The new storage system has arrived

I am happy to be able to say that I've wrapped up the first round of development on [the new storage & query system](https://github.com/starkos/premake-next/tree/master/core/modules/store). I threw [every edge case I could think of](https://github.com/starkos/premake-next/blob/master/core/modules/store/tests/test_query.lua) at it and was able to, eventually, pass them all.

### What's new with the new system?

Learning my lesson from past development, I did my best to make this new version as open-ended and unconstrained as possible.

**A proper API.** The storage and query API have been cleaned up and condensed to make things easier and more powerful for module authors. (Sorry for the inline images, the OpenCollective editor won't allow me to author code blocks?)

```lua
-- create a new query, targeting a particular "environment";
-- returns the global configuration for that environment
local global = store:query({ system='windows', action='vs2019' })

-- from the global scope, get the configuration for a specific workspace
local wks = global:select({ workspaces='Workspace1' })

-- from that workspace, get the configuration for a specific project
local prj = wks:select({ projects='Project1' })
```

**No containers.** Unlike the v5 system, there is no hardcoded "container" hierarchy. "Scopes" are arbitrary and defined by the query author, making new or ad hoc scopes trivial to implement.

```lua
-- configuration for Project1 common to all workspaces
local prj1 = global:select({ projects='Project1' })

-- all DLL configuration
local cfg = global:select({ kind='SharedLib' })
```

**Fine-grained inheritance.** Inheritance in v5 was baked into the system and difficult to modify or work around. The new system allows inheritance to be enabled (or not) between any "scopes", or even on a per-fetch basis.

```lua
-- this project inherits values from the workspace
local prj1 = wks
	:select({ projects='Project1' })
	:inheritValues()

-- this project does not inherit workspace values
local prj2 = wks:
	:select({ projects='Project2' })

-- inheritance can then be enabled for a particular fetch
prj2:inheritValues().fetch('defines')

-- get all configuration specific to the Win64 debug build, without
-- inheriting anything from the project. This was really difficult
-- to do in the previous system
local files = prj2
	:select({ platforms='Win64', configurations='Debug' })
```

**No more file configurations.** This one pleases me greatly: file-level configuration is now no different than anything else. This will make it much easier to implement per-file configuration settings going forward.

```lua
local file = prj:select({ files='Hello.cpp' })
local fileCfg = file:select({ configurations='Debug' })
local fileDefines = fileCfg:fetch('defines')
```

**No "magic" fields.** In v5, certain fields received special processing to enable out-of-order evaluation for situations like the one shown below. This worked for most projects, but not for everyone, and it added extra processing and overhead. The new system is able to handle situations like these as a general case, with no workarounds.

```lua
filter { kind='SharedLib' }  -- don't yet know what `kind` will be
	defines 'DLL_EXPORT'

project 'Project1'
	kind 'SharedLib'   -- need to go back and get that earlier define
```

**Reduced configuration constraints.** It now possible to share projects between workspaces, just as you would any other configuration. Containers which previously required the use of special APIs now work like any other field. Using the v5 scripting syntax (which isn't implemented in the new version), that means you can do things like:

```lua
workspaces { 'Workspace1', 'Workspace2' }
projects { 'Project1', 'Project2' }

filter { 'workspaces:Workspace*' }
	projects { 'Project1' }
```

### On performance

When I announced that I was working on a new system, several people were quick to raise performance as a critical concern. While it is too soon for performance testing—this is just the "keep it simple; make it work" version—I have tried to design the overall approach for optimizability. The new system is simpler and "flatter", provides more opportunities for caching intermediate results, and should translate to C reasonably well. Once the new system has been proven fit for purpose and there are enough features in place to run a real world test I will loop back to complete those optimizations.

### Next steps

All of these improvements and advances are academic until you can actually generate some output, so that's next on my list. In order to cut to the chase and get us to a "v5 vs. v6" decision as quickly as possible, without getting mired in all of the complexities of targeting a specific toolset, I'm planning to build a JSON export module over the new code. (This is something I've wanted in the past to assist with tooling, automation and visualization anyway.) That should allow me to quickly build out the scaffolding and APIs required by all exporters, as well as provide a good testbed for bringing the remaining features online as we move ahead. Feedback on that approach, or alternative suggestions, are welcome.

### v5 vs. v6

It's my hope that with an exporter in place folks will have enough to see and touch to consider where things go next. Do we backport the new code to v5 and rework all of the existing actions, potentially breaking existing projects? Or do we flip the bit on v5, mark it "stable", and push ahead with a v6 instead? (I have an opinion, but keeping an open mind.) When the time comes I'll open an RFC issue on GitHub so everyone can have their say on the matter.

### Feedback is welcome and appreciated!

These are big changes and I welcome questions, suggestions, and concerns. Everything is up for discussion, from the feature set, to the coding style. You can message or DM me at [@premakeapp](https://twitter.com/premakeapp), email at **starkos@industriousone.com**, or open an issue on [the premake-next GitHub project](https://github.com/starkos/premake-next).

And as we do: a shout out to **[CitizenFX Collective](https://opencollective.com/_fivem)** and **[Industrious One](https://opencollective.com/industriousone)** and **[everyone else](https://opencollective.com/premake#section-contributors)** who has helped back us so far. Getting this new system shipped crosses a big dependency off the to-do list, and I'm not sure it ever would have seen the light of day without your help. Many and sincere thanks to all of you! 🙌

~st.

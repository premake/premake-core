---
title: Extending Premake
---

Premake is written almost entirely in [Lua](http://www.lua.org/), the same dynamic language that you use while [writing your project scripts](Your-First-Script.md). Because Lua is dynamic, you can easily replace functions, add new values, and generally run amok in the code to make things work the way you like.

We've structured (or are in the process of structuring, with the intention of being done before the 5.0 release) the code with this feature in mind, adopting coding conventions that make it easy to hook and override or extend Premake's functionality.

### Use the Source! ###

Before you start hacking away, you should be comfortable browsing through the [source code of Premake](http://github.com/premake/premake-core) or [the third-party module](/community/modules) you wish to modify. You will need to be able to identify the Lua function that emits the markup or otherwise implements the feature you wish to change before you can hook into it.

If you haven't already, you should [grab a source code package, or clone the code repository on GitHub](/download) to use as a reference.

Then check out the [Code Overview](Code-Overview.md) to get a general sense of where things live, and [Coding Conventions](Coding-Conventions.md) for an overview on how the code is structured and why we did it that way.

Have a look at [Overrides and Call Arrays](Overrides-and-Call-Arrays.md) to learn more about Premake's extensible coding conventions, and how you can leverage them to easily change its current behavior.

When you're ready, check out the [documentation index](/docs) for more customization topics like adding support for new actions and toolsets, and [how to use modules](Introducing-Modules.md) to package your code up to share with others.

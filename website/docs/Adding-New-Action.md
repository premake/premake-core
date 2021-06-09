---
title: Adding a New Action
---

The Visual Studio, Makefile, and other exporters included in Premake are all "actions". They take the information from your project scripts and perform an action: in these examples, they output project files for specific toolsets.

Premake provides the ability to create your own actions. These can be simple one time operations like preparing a working copy of your source code for first use, or complex support for an entirely new toolset.

This tutorial walks through the process of creating a new action that outputs solution and project information as Lua tables, which you can then use Premake to read and manipulate if you wish.

* [Starting Your New Action](Starting-Your-New-Action.md)
* [Generating Project Files](Generating-Project-Files.md)
* Working with Configurations
* (More to come!)

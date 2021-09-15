---
title: Build Settings
---

Premake provides an ever-growing list of build settings that you can tweak; the following table lists some of the most common configuration tasks with a link to the corresponding functions. For a comprehensive list of available settings and functions, see the [Project API](Project-API.md) and [Lua Library Additions](Lua-Library-Additions.md).

If you think something should be possible and you can't figure out how to do it, see [Support](/community/support).

|                                               |                      |
|-----------------------------------------------|----------------------|
| Specify the binary type (executable, library) | [kind](kind.md) |
| Specify source code files  | [files](files.md), [removefiles](files.md)  |
| Define compiler or preprocessor symbols   | [defines](defines.md)  |
| Locate include files | [includedirs](includedirs.md) |
| Set up precompiled headers | [pchheader](pchheader.md), [pchsource](pchsource.md) |
| Link libraries, frameworks, or other projects | [links](links.md), [libdirs](libdirs.md) |
| Enable debugging information | [symbols](symbols.md) |
| Optimize for size or speed | [optimize](optimize.md) |
| Add arbitrary build flags | [buildoptions](buildoptions.md), [linkoptions](linkoptions.md) |
| Set the name or location of compiled targets | [targetname](targetname.md), [targetdir](targetdir.md) |

---
title: Build Settings
---

Premake provides an ever-growing list of build settings that you can tweak; the following table lists some of the most common configuration tasks with a link to the corresponding functions. For a comprehensive list of available settings and functions, see the [Project API](project-api) and [Lua Library Additions](lua-library-additions).

If you think something should be possible and you can't figure out how to do it, see [Support](/community/support).

|                                               |                      |
|-----------------------------------------------|----------------------|
| Specify the binary type (executable, library) | [kind](kind) |
| Specify source code files  | [files](files), [removefiles](files)  |
| Define compiler or preprocessor symbols   | [defines](defines)  |
| Locate include files | [includedirs](includedirs) |
| Set up precompiled headers | [pchheader](pchheader), [pchsource](pchsource) |
| Link libraries, frameworks, or other projects | [links](links), [libdirs](libdirs) |
| Enable debugging information | symbols(symbols) |
| Optimize for size or speed | [optimize](optimize) |
| Add arbitrary build flags | [buildoptions](buildoptions), [linkoptions](linkoptions) |
| Set the name or location of compiled targets | [targetname](targetname), [targetdir](targetdir) |

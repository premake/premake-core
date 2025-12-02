---
title: buildoutputs
description: Specifies the file outputs of a custom build command or rule.
keywords: [premake, buildoutputs, custom build, outputs, files, project config, rules]
---

Specifies the file outputs of a custom build command or rule.

```lua
buildoutputs { "output" }
```

### Parameters ###

`output` **string[]** - is the file that is created or updated by the custom build command or rule.


### Applies To ###

Project configurations and rules.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [Custom Build Commands](Custom-Build-Commands.md)
* [Custom Rules](Custom-Rules.md)
* [buildcommands](buildcommands.md)
* [builddependencies](builddependencies.md)
* [buildinputs](buildinputs.md)

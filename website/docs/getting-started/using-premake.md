---
title: Using Premake
---

There are no official releases of Premake6 yet, so you'll have to [build it yourself](building-premake.md). Script embedding is not supported yet, so you'll have to run it from the build location for the time being.

```bash
bin/debug/premake6 --version
```

Use `--help` to see the available options.

```bash
bin/debug/premake6 --help
```

## Generating Project Files

```bash
# Target the lastest version Visual Studio supported by Premake
bin/debug/premake6 vstudio

# Target a specific version of Visual Studio
bin/debug/premake6 vstudio=2017
```

Here are some of the most common actions out of the box; see [About Actions](/actions/about-actions.md) for the complete list.

| Action          | Description                                        |
|-----------------|----------------------------------------------------|
| [vstudio][vsx]  | Generate Visual Studio solution & projects (C/C++) |

Other actions may be added via third-party modules, see [Modules](/community/modules).


[vsx]: /actions/vstudio.md

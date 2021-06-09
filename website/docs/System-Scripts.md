---
title: System Scripts
---

Immediately after startup, Premake will look for and run a *system script*. It does this before handling actions and other arguments, and before loading the project script, if present. The system script is a great place for adding [modules](Using-Modules.md) and other support code that you wish to include in all of your Premake-enabled projects.

By default, this file is named `premake-system.lua` or `premake5-system.lua`, and should be located [somewhere on Premake's search paths](Locating-Scripts.md).

You can override the default system script file name and location using the `--systemscript` command line argument.

```
$ premake5 /systemscript=../scripts/my_system_script.lua vs2010
```

There is nothing particularly special about this file other than its run-first priority. You can put any Premake code in the system script, including configurations, workspaces, and projects.

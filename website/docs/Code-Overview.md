---
title: Code Overview
---

## A Quick Tour of Premake ##

The Premake source code is organized into a few different folders:

* `src/actions` contains the code for the built-on actions and exporters, e.g. "vs2012" or "gmake". We are gradually migrating these into independent modules, but for now they live here.

* `src/base` contains the core Lua scripts, the code that is used to read and process your project scripts, and supporting logic for the actions and exporters.

* `src/host` contains all of the C language code, logic that either can't easily be written in Lua because of the way it needs to interact with the underlying operating system, or because a Lua implementation would be too slow. We try to keep C code to a minimum and use Lua whenever we can, to enable [overrides and call arrays](Overrides-and-Call-Arrays.md).

* `src/tools` contains the adapters for command line toolsets like GCC and Clang. We will probably be migrating these toward modules in the near-ish future as well.

* `modules` contains the official set of modules which are distributed as part of Premake. These modules add support for additional languages and toolsets to the core code in the `src` folder.

In addition to those general categories, there are a few special files of note:

* `src/_premake_main.lua` contains the Lua-side program entry point, and is responsible for the main application flow. The C-side program entry point `main()` is located in `src/host/premake_main.c`.

* `src/_premake_init.lua` sets up much of the initial configuration, including all of the project scripting functions, the default set of command line arguments, and the default project configurations.

* `src/_modules.lua` contains the list of built-in modules which are automatically loaded in startup. See [Embedding Modules](Embedding-Modules.md) for more information.

* `src/_manifest.lua` lists the Lua scripts that should be embedded into the Premake executable when making the release builds. There are separate manifests for Premake's core scripts and each embedded module.


## Code Execution Overview ##

Execution starts at `main()` in `src/host/premake_main.c`, which calls into to `src/host/premake.c` to do the real bootstrapping work:

* `premake_init()` installs all of Premake's native C extensions to the Lua scripting environment.

* `premake_execute()` finds and runs `src/_premake_main.lua`, which may be embedded into the executable for a release build, or located on the filesystem.

* `src/_premake_main.lua` in turn reads `src/_manifest.lua` and loads all of the scripts listed there. Notably, this includes `src/_premake_init.lua` which does

* Once `src/premake_main.lua` has finished, `premake_execute()` calls `_premake_main()`, which located at the end of `src/_premake_main.lua`, and waits for it to return.

At this point, execution has moved into and remains in Lua; [extending Premake by overriding functions and call arrays](Overrides-and-Call-Arrays.md) now becomes possible.

`_premake_main()` uses a [call array](Overrides-and-Call-Arrays.md) to control the high-level process of evaluating the user scripts and acting on the results. Notable functions in this list include:

* `prepareEnvironment()` sets more global variables and otherwise gets the script environment ready to use.

* `locateUserScript()` handles finding the user's project script, i.e. `premake5.lua` on the file system.

* `checkInteractive()` is responsible for launching the REPL prompt, if requested.

* `runSystemScript()` runs [the user's system script](System-Scripts.md), and `runUserScript()` runs the project script found by `locateUserScript()`.

* `processCommandLine()` handles any command line options and sets the target action and arguments. This needs to happen after the project script has run, in case it defines new options or modifies the behavior of existing options&mdash;a common point of confusion.

* `bake()` takes all of the project and configuration information that has been specified in the user's project script and prepares it for use by the target action, a somewhat convoluted process that is implemented in `src/base/oven.lua`.

* `validate()` examines the processed configuration information and tries to make sure it all makes sense, and that all required data is available. The main validation logic is located in `src/base/validation.lua`.

* `callAction()` passes each workspace, project, rule, and other container to the target action, causing the appropriate result--like generating a Visual Studio project or GNU makefile--to occur. This container iteration is done in `action.call()` in `src/base/action.lua`.

Calling the action, via `callAction()`, is where the interesting part for most people begins. Control now transfers to one of exporters, causing the project files to be written. For more information on how *that* happens, see [Creating a New Action](Adding-New-Action.md).


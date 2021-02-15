---
title: Building Premake
---

If you downloaded a prebuilt binary package you can skip this page, which discusses how to build the Premake source code. Jump ahead to [Quick Start](Premake-Quick-Start.md) to begin learning how to use and develop with Premake.

## Generating the Project Files ##

If you downloaded one of the [official source code release packages](http://sourceforge.net/projects/premake/files/), the project files have already been generated for you, and may be found in the **build/** directory. Skip ahead to the next section to learn about the important differences between the build configurations.

Premake's [Git repository](https://github.com/premake/premake-4.x) does not contain any project files. Instead, use an [existing copy of Premake](http://premake.github.io/premake-core/download.html) to generate the files for your particular toolset and environment.

Once you have a working Premake installed, embed the scripts by opening a console or terminal to the source code directory and running the command

```bash
premake4 embed
```

Now generate the project files with a command like:

```bash
premake4 gmake    # for GNU makefiles using GCC
premake4 vs2008   # for a Visual Studio 2008 solution
```

Use the --help option to see all of the available targets. You now have a solution/makefile/workspace that you can load and build.

Note that when working against the Git sources it is a good idea to refresh the embedded scripts after each update.

```bash
git pull -u
premake4 embed
```

See **Debug vs. Release Modes** below for an explanation (and maybe eventually I'll think of a better way to do this).

## Building the Source Code ##

Premake can be built in either "release" (the default) or "debug" modes. If you are using Makefiles (as opposed to an IDE), you can choose which configuration to build with the **config** argument:

```bash
make               # build in release mode, both versions
make config=debug  # build in debug mode, when generated with Premake 4.x
make CONFIG=Debug  # build in debug mode, when generated with Premake 3.x
```

If you do not supply a **config** argument, release mode will be used. IDEs like Visual Studio provide their own mechanism for switching build configurations.

## Debug vs Release Modes ##

A significant portion of Premake is written in Lua. For release builds (the default) this has no impact, just build as normal and go.

When built in Debug mode, Premake will read its Lua scripts from the disk at startup, enabling compile-less code/test iterations, and therefore faster development. But it needs a little help finding the scripts. You can use the **/scripts** command line argument, like so:

```bash
premake4 /scripts=~/Code/premake4/src gmake
```

Or set a **PREMAKE_PATH** environment variable:

```bash
PREMAKE_PATH=~/Code/premake4/src
```

You need to specify the location of the Premake **src/** directory, the one containing **_premake_main.lua**.

## Embedding the Scripts ##

In release builds, Premake uses a copy of the scripts embedded into static strings: see **src/host/scripts.c**. If you modify any of the core Lua scripts (anything ending in **.lua**), you must also update these embedded strings before your changes will appear in the release mode build.

You can update these strings by using the **embed** action, which is part of Premake's own build script.

```bash
premake4 embed
```

This command embeds all of the scripts listed in **_manifest.lua** into **src/host/scripts.c**. The next release build will include the updated scripts.

## Confused? ##

The inclusion of the Lua scripts throws a wrench in things, and I certainly understand if you have questions. I'll be glad to help you out. Leave a note [in the forums](https://groups.google.com/forum/#!forum/premake-development). Your questions will help me improve these instructions.

---
title: Your First Script
---

Let's start by configuring a build for the traditional ["Hello, world!" program](https://en.wikipedia.org/wiki/%22Hello,_world!%22_program), as written in C:

```c
/* hello.c */
#include <stdio.h>

int main(void) {
   puts("Hello, world!");
   return 0;
}
```

The Premake script for a typical C program, such as this example, would be:

```lua
-- premake5.lua
workspace "HelloWorld"
   configurations { "Debug", "Release" }

project "HelloWorld"
   kind "ConsoleApp"
   language "C"
   targetdir "bin/%{cfg.buildcfg}"

   files { "**.h", "**.c" }

   filter "configurations:Debug"
      defines { "DEBUG" }
      symbols "On"

   filter "configurations:Release"
      defines { "NDEBUG" }
      optimize "On"
```

If you save this script as a file named `premake5.lua`, and place it in the same directory as `hello.c` above, you can then generate project files by running a command like this one:

```bash
$ premake5 vs2013
```

This particular command will generate `HelloWorld.sln` and `HelloWorld.vcxproj` files for Visual Studio 2013 (see [Using Premake](Using-Premake.md) or run `premake --help` for a complete list of exporters). If you build the generated workspace, you will get a command line executable named `HelloWorld.exe` in the `bin/Debug` or `bin/Release` directory, depending on which configuration was selected within Visual Studio.

If you happened to be on Linux, you could generate and build a makefile like so:

```bash
$ premake5 gmake
$ make                # build default (Debug) configuration
$ make config=release # build release configuration
$ make help           # show available configurations
```

If you'd like to use a name for your script other than the default "premake5.lua", use Premake's `--file` argument to tell it which file it should load.

```bash
$ premake5 --file=MyProjectScript.lua vs2013
```


## What's Going On Here? ##

Through the rest of this manual I'll break this sample down and walk through all of the features of Premake in a somewhat logical fashion. It isn't rocket science, and you probably already have the gist of it from the example above, so feel free to skip around. But first, it is helpful to know a few things about Premake scripts in general.


### Premake is Lua ###

Premake is built on [Lua](http://www.lua.org/about.html), a powerful, fast, lightweight scripting language. Premake scripts are really Lua programs, so anything you can do in Lua can also be done in a Premake script.

Premake builds on the Lua runtime, adding functions for defining workspaces, projects, and configurations as well as common build and file management tasks. It also provides conventions for setting your own command line options and arguments, allowing for construction of sophisticated build configuration and automation scripts.

Because of the descriptive nature of the Lua language, your build scripts will often look more like static configuration files than mini-programs, as you can see from the example above.

You can [learn more about Lua here](http://www.lua.org/about.html) or from their [excellent reference manual](http://www.lua.org/manual/5.3/), but here's what you need to know to understand this example:

* The identation whitespace is arbitrary; this is the way I happen to like it.

* A double dash "--" starts a single line comment.

* Curly braces "{" and "}" are used to denote lists of values.


### Functions and Arguments ###

Each line in the sample script is actually a function call. When you call a Lua function with a simple string or table argument you may omit the usual parenthesis for readability. So the first two lines of the sample could also be written as:

```lua
workspace("HelloWorld")
configurations({ "Debug", "Release" })
```

If you use anything *other* than a simple string or table, the parenthesis become mandatory.

```lua
local lang = "C++"
language (lang)  -- using a variable, needs parenthesis

workspace("HelloWorld" .. _ACTION) -- using string concatenation, needs parenthesis
```


### Values and Lists ###

Most of Premake's functions accept either a single string or a list of strings as arguments. Single string arguments are easy to use and understand.

```lua
language "C++"
```

If multiple values are encountered for a simple value, the last one seen wins.

```lua
language "C++"   -- the value is now "C++"
language "C"     -- the value is now "C"
```

For functions that accept a list of values, you may supply a list using Lua's curly brace syntax, or a single string value.

```lua
defines { "DEBUG", "TRACE" }  -- defines multiple values using list syntax
defines { "NDEBUG" }           -- defines a single value using list syntax
defines "NDEBUG"              -- defines a single value as a simple string
```

If multiple values are encountered for a list, they are concatenated.

```lua
defines { "DEBUG", "TRACE" }  -- value is now { "DEBUG", "TRACE" }
defines { "WINDOWS" }         -- value is now { "DEBUG", "TRACE", "WINDOWS" }
```

If you ever wish to remove a previously set value, all list functions define a corresponding remove...() call.

```lua
defines { "DEBUG", "TRACE" }  -- value is now { "DEBUG", "TRACE" }
removedefines { "TRACE" }     -- value is now { "DEBUG" }
```


### Paths ###

You'll be specifying lots of paths in your Premake scripts. There are two rules to remember:

* Always specify paths relative to the script file in which they appear.

* Always use forward slashes ("/") as a path separator. Premake will translate to the appropriate separator when generating the output files.


---
title: Basic Premake Extension
---

*Some things you should know before you digging into the Premake internals, in no particular order:*

## Managing script files ##

Before you begin, you should be able to [build and run the debug configuration of Premake](Building-Premake.md). This will save you the trouble of embedding the scripts and recompiling with each change, and will greatly speed up development.

When you have completed your changes and are ready to roll them out, note that you must run `premake4 embed` and recompile in order to see your changes in the release build of Premake. Debug builds load the scripts dynamically at startup and so can skip this step.

Premake knows which scripts to load and run by reading the file `src/_manifest.lua`. Any new script file you create must be listed in the manifest if you want it to run. This is a common mistake; I still make it myself every once in a while.

The command `premake4 embed` copies all of the scripts listed in the manifest into static C buffers in the file `src/host/scripts.c`, which then gets compiled into the final executable. This is how I can ship a single binary, rather than the whole source tree.

## Testing ##

There is a fairly comprehensive set of automated tests in the `tests/` folder. Create a debug build of Premake and then, in this tests directory, run the command:

```
../bin/debug/premake4 test
```

Or, if you're in a POSIX environment, run the `./test` shell script. I am using my own homegrown testing framework, which is defined in `tests/testfx.lua`. You can add new test files in `tests/premake4.lua`.

## Namespaces ##

Lua allows the creation of namespaces (of a sort) by putting your functions into a table. This example creates a function `bar` in the namespace `premake.foo`.

```lua
premake.foo = { }

function premake.foo.bar()
  -- do something useful
end
```

I have begun moving all of Premake's internals into the *premake* namespace, but it is a work in progress.

## And finally... ##

Finally, [post any questions you might have over in the forums](https://groups.google.com/forum/#!forum/premake-development) and I will be delighted (yes, delighted) to help you out. Your questions will help me improve this documentation and Premake itself and are very much appreciated.

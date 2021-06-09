---
title: Locating Scripts
---

When Premake needs to load a script file, via a call to `dofile()` or `include()`, or a module via a call to `require()`, it uses the `premake.path` variable to locate it. This is a semicolon-delimited string which, by default, includes the following locations, in the specified order:

* Relative to the currently executing script

* On the path specified by the `--scripts` command line argument

* On the paths listed in the `PREMAKE_PATH` environment variable

* In the `~/.premake` directory

* In the `~/Library/Application Support/Premake` directory (Mac OS X only)

* In the `/usr/local/share/premake` directory

* In the `/usr/share/premake` directory

* In the directory containing the currently running Premake executable.

Note that these search paths also work for modules (e.g. `~/.premake/monodevelop`) and [system scripts](System-Scripts.md).

You are free to add or remove paths from `premake.path`, in either your project or system scripts. Any requests to load scripts after the change will use your modified path.

---
title: Locating Scripts
---

When Premake needs to load a script file, such as a call to `doFile()` or `require()`, it uses the current contents of the `_PREMAKE.PATH` variable to determine where to search.

`_PREMAKE.PATH` is an array of paths, indexed in the order which they should be searched. By default, the search order is:

1. Relative to the current value of [`_SCRIPT_DIR`](_SCRIPT_DIR.md)
2. On the path specified by the `--scripts` command line argument, if present
3. In Premake's own collection of internal scripts (Premake release builds only)
4. Relative to the current working directory
5. On the paths listed in the `PREMAKE6_PATH` environment variable
6. In the `~/.premake` directory
7. In the `~/Library/Application Support/Premake` directory (macOS only)
8. In the `/usr/local/share/premake` directory
9. In the `/usr/share/premake` directory
10. Relative to the current value of [`_PREMAKE.COMMAND_DIR`](_PREMAKE.md)

When searching for modules loaded with `require('name')`, Premake will try the following naming patterns at each search location:

1. `name/name.lua`
2. `modules/name/name.lua`
3. `.modules/name/name.lua`
4. `name.lua`
5. `modules/name.lua`
6. `.modules/name.lua`

You are free to add or remove paths from `_PREMAKE.PATH`, in either your project or system scripts. Any requests to load scripts after the change will use your modified path.

In addition to static string values, you may also insert functions into the array. At file load time, Premake will pass the file being located to your function. Return the actual path to the file if found, or `nil` to continue searching.

# _PREMAKE.PATH

A list of paths to be searched whenever Premake needs to load a script or module, such as via calls to **doFile()** or **require()**. The paths are tried in the order they appear in this table. By default, `_PREMAKE.PATH` contains these values, in this order:

1. Relative to the current value of [_SCRIPT_DIR](api/_SCRIPT_DIR.md)

2. On the path specified by the `--scripts` command line argument, if present

3. In Premake's own collection of internal scripts (Premake release builds only)

4. Relative to the current working directory

5. On the paths listed in the `PREMAKE6_PATH` environment variable

6. In the `~/.premake` directory

7. In the `~/Library/Application Support/Premake` directory (macOS only)

8. In the `/usr/local/share/premake` directory

9. In the `/usr/share/premake` directory

10. In the directory containing the currently running Premake executable.

When searching for modules (i.e. **require('name')**), Premake will try the following naming patterns:

1. `name/name.lua`

2. `modules/name/name.lua`

3. `.modules/name/name.lua`

4. `name.lua`

5. `modules/name.lua`

6. `.modules/name.lua`

You are free to add or remove paths from `_PREMAKE.PATH`, in either your project or system scripts. Any requests to load scripts after the change will use your modified path.

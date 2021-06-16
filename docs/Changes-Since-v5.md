# Changes since Premake5

This is my best attempt to keep track of all the notable changes introduced in 6.x. If you spot anything I missed, open an issue to let me know!

## The Big Stuff

#### Exporters now default to latest version

Tool vendors are moving to more "fluid" releases, and significant changes are no longer limited to major releases. The expectation is that most developers will stay up-to-date with the most recent version (whether they like it or not!). In this new world, Premake's one-exporter-per-major-version approach isn't holding up. Instead, exporters now register a single action per toolset with an optional argument to specify the version. If not specified, the most recent version is targeted.

```sh
# Target the latest version
$ premake6 vstudio
$ premake6 xcode

# Target a specific version
$ premake vstudio=2017
$ premake6 xcode=9

# This doesn't work yet, but maybe someday...
$ premake vstudio=14.0.25431.01
```

#### Internals have been rewritten

In addition to a [completely new storage and query system]((https://opencollective.com/premake/updates/community-update-5), the codebase has been thoroughly reworked to standardize coding conventions, improve extensibility, and (hopefully) stablize the APIs for future module developers. The code has also been reorganized to be more module-oriented; features are now loaded on-demand for faster startup time and lower resource usage.

#### Symbols are now Camel Case

All symbols, both internal and public facing, have been standardized on [camelCase](https://en.wikipedia.org/wiki/Camel_case), ex. `string.startswith()` is now `string.startsWith()`. This includes Lua's built-in functions as well, ex. `doFile()` and `loadFile()`. In previous versions I tried to match Lua's `alllowercasenoseparators` standard but it only resulted in unreadable code.

#### Current working directory is now maintained

Previous versions would set the working directory to the location of the last loaded script file. The current working directory is now left intact; use `_SCRIPT_DIR` to create script relative paths at runtime.


## Smaller improvements

- **No longer modifies the Lua runtime.** You can now choose to link Premake against the system's Lua library in order to interoperate with third-party binary Lua modules.

- **Less global namespace clutter.** In particular, the `premake` and `path` globals are gone; you'll now need to require them (or not) as needed.

```lua
local premake = require('premake')
local path = require('path')
```

- **System script runs earlier.** The system script is now run earlier in the bootstrap process, enabling third-party modules more opportunities to modify that process.

- **Improved command line option model and parsing.** The distinction between "options" and "actions" has been removed. All arguments may now specify an `execute()` method. The "=" is now optional when assigning values from the command line. The `_OPTIONS` global has been removed; use the `options` module for direct programmatic access.

- **Preload magic replaced with `register()`.** Previously only core modules could register command line options and other settings on startup without actually loading the entire module. Any modules may now include a `register.lua` script which can be loaded with `register('moduleName')`. See [the testing module](../modules/testing) for an example.

- **Exporters get more responsility.** The division of responsibilities has been shifted to give exporters significantly more control over how data is queried, inherited, and exported.


## API Changes

- As mentioned above, all APIs now use camel-case: `string.startswith` is now `string.startsWith`, etc.

#### _G

- Most global variables are now gathered under a new `_PREMAKE` global: `_PREMAKE.COMMAND`, `_PREMAKE.COMMAND_DIR`, `_PREMAKE.MAIN_SCRIPT`, `_PREMAKE.MAIN_SCRIPT_DIR`, `_PREMAKE.PATH`

- `_PREMAKE.PATH` (was `premake.path`) is now an array of paths rather than a semicolon separated string. You may also put functions in this list, which are called at file load time to resolve the path to be searched.

- `doFile()` now accepts an optional list of arguments to pass to the called script

### os

- `os.writefile_ifnotequal()` has been split into `io.writeFile()` and `io.compareFile()`

### premake

- `premake.generate()` is now `premake.export()`, and uses a different signature

- The `workspace`, `project`, and `config` libraries have been moved to a new `dom` module

- Export-related functions (`capture`, `w`, `eol`, etc.) have been moved to the `export` module. Some shortcuts such as `p.w()` and `p.x()` have been dropped; see the provided export modules for examples of the new syntax.

#### table

- API reworked to distinguish between array and dictionary operations

#### terminal

- `terminal.textColor()` has replaced `getTextColor` and `setTextColor`

#### testing

-  Test module name changed from `self-test` to `testing`

-  `--test-only` option now supports "*" wildcards and multiple, comma-separated patterns, ex. `--test-only="string,os"`

- Test output is now quieter by default; use `--verbose` flag to enable detailed out

- Modules may now register pre- and post-test hooks to allow module state to be captured and restored around test boundaries

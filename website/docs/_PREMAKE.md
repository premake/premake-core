This global table contains information about the current Premake runtime environment.

#### `_PREMAKE.COMMAND`

The full absolute path to the currently executing Premake executable, including the executable file name and extension.

#### `_PREMAKE.COMMAND_DIR`

The full absolute path to the directory containing the currently executing Premake executable.

#### `_PREMAKE.PATH`

An array of paths to be searched whenever Premake needs to load a script or module, such as a call to `doFile()` or `require()`. See [authoring/locating-scripts.md] for a full explanation.

### See Also

- [Locating Scripts](authoring/locating-scripts.md)
- [`_ARGS`](_ARGS)
- [`_SCRIPT`](_SCRIPT.md)
- [`_SCRIPT_DIR`](_SCRIPT_DIR.md)
- [`_USER_HOME_DIR`](_USER_HOME_DIR.md)

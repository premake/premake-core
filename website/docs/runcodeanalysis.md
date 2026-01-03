Runs code analysis during the build process for Visual Studio projects.

The `runcodeanalysis` option enforces code analysis during the build process in Visual Studio projects. This may significantly increase build time for projects.

```lua
runcodeanalysis ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Run code analysis during build of projects. |
| Off   | Do not run code analysis during build of projects. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta3 or later for Visual Studio 2019 and later.

### Examples ###

Run clang-tidy code analysis during the build process.

```lua
clangtidy("On")
runcodeanalysis("On")
```

### See Also ###
* [Run Code Analysis](https://learn.microsoft.com/en-us/cpp/code-quality/quick-start-code-analysis-for-c-cpp?view=msvc-170#run-code-analysis)
* [Using Clang-Tidy in Visual Studio](https://learn.microsoft.com/en-us/cpp/code-quality/clang-tidy?view=msvc-170)
* [clangtidy](clangtidy.md)

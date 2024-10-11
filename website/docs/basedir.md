Sets the base directory for a workspace or project, from which other paths contained by the configuration will be made relative to.

This base directory is also used when expanding path tokens encountered in non-path values.
Such values will be made relative to this value so the resulting projects will only contain relative paths.

```lua
basedir ("value")
```

You do not normally need to set this value, as it is filled in automatically with the current working directory at the time the configuration block is created by the script.

### Parameters ###

`value` is an absolute or relative path, from which other paths contained by the configuration should be made relative to.

### Applies To ###

Any configuration.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
workspace "workspace"
basedir "base"
project "project"
    files { "file.cpp" }
    includedirs { "dir" }
```

In this case, files will be generated as `base/file.cpp`, and the include directory as `base/dir`.


```lua
basedir "root"
workspace "workspace"
project "project"
    basedir "base"
    files { "file.cpp" }
    includedirs { "dir" }
```

This results in the same output, as the project-level `basedir` overrides the workspace-level value.

```lua
filter { "configurations:Debug" }
    includedirs { "%{prj.basedir}" }
```

`basedir` can also be used as a token, via for example `%{prj.basedir}` syntax. See the [Tokens](Tokens.md) reference for more details.

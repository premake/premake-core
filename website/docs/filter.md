Limits the subsequent build settings to a particular environment.

```lua
filter { "prefix:keywords" }
```

Any settings that appear after this function in the script will be applied only to those contexts that match all of the listed keywords. See below for some usage examples.

### Parameters ###

`keywords` is a list of identifiers, prefixed by the field against which they should be tested. When all of the keywords in this list match the current context, the settings that follow the `filter` statement will be applied. If any of the keywords fail this test, the settings are ignored. Keywords may contain wildcards, and are not case-sensitive. See below for examples.

Each keyword must include a prefix to specify which field should be tested. The following field prefixes are currently supported:

  * [action](globals/premake_ACTION.md)
  * [architecture](architecture.md)
  * [configurations](configurations.md)
  * [files](files.md)
  * [kind](kind.md)
  * [language](language.md)
  * [options](globals/premake_OPTIONS.md)
  * [platforms](platforms.md)
  * [system](system.md)
  * [tags](tags.md)
  * [toolset](toolset.md)

Keywords may use the `\*` and `\*\*` wildcards to match more than one term or file. You may also use the modifiers `not` and `or` to build more complex conditions. Again, see the examples below for more information.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Define a new symbol which applies only to debug builds.

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }

filter "configurations:Debug"
  defines { "_DEBUG" }
```

If no field prefix is specified in the keyword, "configurations" is used as a default.

```lua
filter "Debug"
  defines { "_DEBUG" }
```

Define a symbol only when targeting Visual Studio 2010.

```lua
filter "action:vs2010"
  defines { "VISUAL_STUDIO_2005" }
```

Wildcards can be used to match multiple terms. Define a symbol for all versions of Visual Studio.

```lua
filter "action:vs*"
  defines { "VISUAL_STUDIO" }
```

The **or** modifier may be used when several values are possible. Define a value just for library targets.

```lua
filter "kind:SharedLib or StaticLib"
  defines { "LIBRARY_TARGET" }
```

When multiple keywords are listed, an implicit **and** is assumed between them. Define compiler options only when using GNU Make and GCC.

```lua
filter { "action:gmake*", "toolset:gcc" }
  buildoptions {
    "-Wall", "-Wextra", "-Werror"
  }
```

If any keyword pattern fails to match the current context, the entire filter is skipped over. Lua's curly bracket list syntax must be used when multiple keywords are present.

Add a suffix to the debug versions of libraries.

```lua
-- (configurations == "Debug") and (kind == SharedLib or kind == "StaticLib")
filter { "Debug", "kind:SharedLib or StaticLib" }
  targetsuffix "_d"

-- Could also be written as
filter { "Debug", "kind:*Lib" }
  targetsuffix "_d"
```

Apply settings based on the presence of a [custom command line option](Command-Line-Arguments.md).

```lua
-- Using an option like --localized
filter "options:localized"
  files { "src/localizations/**" }

-- Using an option like --renderer=opengl
filter "options:renderer=opengl"
  files { "src/opengl/**.cpp" }
```

Although support is currently limited, you may also apply settings to a particular file or set of files. This example sets the build action for all PNG image files.

```lua
filter "files:*.png"
  buildaction "Embed"
```

In the case of files you may also use the **\*\*** wildcard, which will recurse into subdirectories.

```lua
filter "files:**.png"
  buildaction "Embed"
```

You can also use **not** to apply the settings to all environments where the identifier is not set.

```lua
filter "system:not windows"
  defines { "NOT_WINDOWS" }
```

You can combine different prefixes within a single keyword.

```lua
filter "system:windows or language:C#"
```

Finally, you can reset the filter and remove all active keywords by passing the function an empty table.

```lua
filter {}
```

### Clarifying Notes ###

* When a filter is set, any previous filter operations will become inactive.  In other words, initiating a filter acts as though a reset occurred first, followed by setting a new filter condition.

* Filters can be viewed as a scoping concept.  A currently set filter goes 'out of scope' when either a filter reset operation is invoked or a project definition is started.

* Filters are whitespace sensitive. For example, a filter of `system:not windows` is fundamentally different from `system: not windows`.

### See Also ###

* [Filters](Filters.md)

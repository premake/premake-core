Limits the subsequent build settings to a particular environment.

```lua
configuration { "keywords" }
```

**This function has been deprecated in Premake 5.0 beta1.** Use the new [filter()](filter.md) function instead; you will get more granular matching and much better performance. `configuration()` will be not supported in Premake 6.

### Parameters ###

`keywords` is a list of identifiers (see below). When all of the keywords in this list match Premake's current context, the settings that follow the `configuration` statement will be applied. If any of the identifiers are not in the current context the settings will be ignored.

The available sources for keywords. Keywords are not case-sensitive.

* **Configuration names.** Any of the configuration names supplied to the **[configurations](configurations.md)** or **[platforms](platforms.md)** functions.

* **Action names** such as **vs2010** or **gmake**. See the [Using Premake](Using-Premake.md) for a complete list.

* **Command line options**.

* **System names** such as **windows**, **macosx**, or **xbox360**.

* **Architectures** such as **x32** or **x64**.

* **Toolsets** such as **gcc**.

* **Target kinds** like **ConsoleApp** or **SharedLib**.

* **Languages** like **C++** or **C#**.

* **File names** can be used to apply settings to a specific set of source code files; this feature is currently very limited.

In addition to the terms listed above, you may use the **\*** and **\*\*** wildcards to match more than one term or file. You may also use the modifiers **not** and **or** to build more complex conditions. See the examples below for more information.

### Examples ###

Define a new symbol which applies only to debug builds; assumes a configuration named "Debug" was defined as part of the workspace.

```lua
configuration "Debug"
  defines { "_DEBUG" }
```

Define a symbol only when targeting Visual Studio 2010.

```lua
configuration "vs2010"
  defines { "VISUAL_STUDIO_2005" }
```

Wildcards can be used to match multiple terms. Define a symbol for all versions of Visual Studio.

```lua
configuration "vs*"
  defines { "VISUAL_STUDIO" }
```

Add a suffix to the debug versions of libraries.

```lua
configuration { "Debug", "SharedLib or StaticLib" }
  targetsuffix "_d"

-- ...or...
configuration { "Debug", "*Lib" }
  targetsuffix "_d"
```

Apply settings based on the presence of a [custom command line option](Command-Line-Arguments.md).

```lua
-- Using an option like --localized
configuration { "localized" }
   files { "src/localizations/**" }

-- Using an option like --renderer=opengl
configuration { "renderer=opengl" }
   files { "src/opengl/**.cpp" }
```

Although support is currently quite limited, you may also apply settings to a particular file or set of files. This example sets the build action for all PNG image files.

```lua
configuration "*.png"
  buildaction "Embed"
```

In the case of files you may also use the **\*\*** wildcard, which will recurse into subdirectories.

```lua
configuration "**.png"
  buildaction "Embed"
```

If multiple keywords are specified, they will be treated as a logical AND. All terms must be present for the block to be applied. This example will apply the symbol only for debug builds on Mac OS X.

```lua
configuration { "debug", "macosx" }
  defines { "DEBUG_MACOSX" }
```

Multiple terms must use Lua's curly bracket list syntax.

You can use the **or** modifier to match against multiple, specific terms.

```lua
configuration "linux or macosx"
  defines { "LINUX_OR_MACOSX" }
```

You can also use **not** to apply the settings to all environments where the identifier is not set.

```lua
configuration "not windows"
  defines { "NOT_WINDOWS" }
```

Finally, you can reset the configuration filter and remove all active keywords by passing the function an empty table.

```lua
configuration {}
```

### Availability ###

Premake 4.0 or later. Will be deprecated at some point in 5.x development in favor of [filter()](filter.md).

### See Also ###

* [Filters](Filters.md)
* [filter](filter.md)

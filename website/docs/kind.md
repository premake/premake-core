Sets the kind of binary object being created by the project or configuration, such as a console or windowed application, or a shared or static library.

```lua
kind ("kind")
```

### Parameters ###

`kind` is one of the following string identifiers:

| Value       | Description                                             |
|-------------|---------------------------------------------------------|
| ConsoleApp  | A console or command-line application.                  |
| WindowedApp | An application which runs in a desktop window. This distinction does not apply on Linux, but is important on Windows and Mac OS X. |
| SharedLib   | A shared library or DLL.                                |
| StaticLib   | A static library.                                       |
| Makefile    | A special configuration type which calls out to one or more external commands. The actual type of binary created is unspecified. See [Makefile Projects](Makefile-Projects.md) for more information. |
| Utility     | A configuration which contains only custom build rules. |
| None        | A configuration which is not included in the build. Useful for projects containing only web pages, header files, or support documentation. |
| Packaging   | A configuration type to create .androidproj files, which build the apk in an Android application under Visual Studio. _Note, this was previously `AndroidProj`._ |
| SharedItems | A special configuration type which doesn't contain any build settings of its own, instead using the build settings of any projects that link it. |


### Applies To ###

Project configurations.

### Availability ###

The **Makefile** kind is available in Premake 5.0.0-alpha1 and later, and are supported for Visual Studio and Codelite.
The **None** kind is available in Premake 5.0.0-alpha1 and later, and are supported for gmakelegacy, gmake, Codelite, Ninja, and Visual Studio.
The **Utility** kind is only available for Visual Studio, Codelite and gmake, as well as very limited support in gmakelegacy.
The **SharedItems** kind is only available for Visual Studio 2013 and later.

### Examples ###

Set the project to build a command-line executable.

```lua
kind "ConsoleApp"
```

Set the project to build a shared library (DLL).

```lua
kind "SharedLib"
```

Build either a static or a shared library, depending on the selected build configuration.

```lua
workspace "MyWorkspace"
   configurations { "DebugLib", "DebugDLL", "ReleaseLib", "ReleaseDLL" }

project "MyProject"

   filter "*Lib"
      kind "StaticLib"

   filter "*DLL"
      kind "SharedLib"
```

### See Also ###

* [Makefile Projects](Makefile-Projects.md)

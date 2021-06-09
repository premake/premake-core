---
title: Workspaces & Projects
---

For convenience, Premake follows the Visual Studio conventions for structuring a build and the naming of its components.


## Workspaces ##

At the top level of every build is a *workspace*, acting as a container for *projects*. Other tools, notably Visual Studio, may use the term *solution*.

Workspaces define a common set of [build configurations and platforms](Configurations-and-Platforms.md) to be used across all of the contained projects. You may also specify additional build settings (defines, include paths, etc.) at this level which will be similarly inherited by the projects.

Workspaces are defined using the [`workspace`](workspace.md) function. Most builds will need only a single workspace, but you are free to create more if needed. Build configurations are specified using the [`configurations`](configurations.md) function and are required; see [Configurations and Platforms](Configurations-and-Platforms.md) for more information.

```lua
workspace "HelloWorld"
   configurations { "Debug", "Release" }
```

The workspace name, provided as a parameter to the function, is used as the default file name of the generated workspace file, so it is best to avoid special characters (spaces are okay). If you wish to use a different name use the [`filename`](filename.md) function to specify it.

```lua
workspace "Hello World"
   filename "Hello"
   configurations { "Debug", "Release" }
```

*(Note: Due to [a bug in the way Xcode handles target dependencies](http://stackoverflow.com/questions/1456806/xcode-dependencies-across-different-build-directories), we currently don't generate a "workspace" file for it.


## Projects ##

The primary purpose of a workspace is to act as a container for projects. A *project* lists the settings and source files needed to build one binary target. Just about every IDE uses the term "project" for this. In the world of Make, you can think of projects as a makefile for one particular library or executable; the workspace is a meta-makefile that calls each project as needed.

Projects are defined using the [`project`](project.md) function. You must create the containing workspace first.

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }

project "MyProject"
```

The project name, like the workspace name, is used as the file name for the generated project file so avoid special characters, or use the [`filename`](filename.md) function to provide a different value.

Each project specifies a *kind* which determines what kind of output is generated, such as a console or windowed executable, or a shared or static library. The [`kind`](kind.md) function is used to specify this value.

Each project also specifies which programming language it uses, such as C++ or C#. The [`language`](language.md) function is used to set this value.

```lua
project "MyProject"
  kind "ConsoleApp"
  language "C++"
```


## Locations ##

By default, Premake will place generated workspace and project files in the same directory as the script which defined them. If your Premake script is in `C:\Code\MyProject` then the generated files will also be in `C:\Code\MyProject`.

You can change the output location using the [location](location.md) function.

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }
  location "build"

project "MyProject"
  location "build/MyProject"
```

Like all paths in Premake, the [location](location.md) should be specified relative to the script file. Using the example and script above, the generated workspace will be placed in `C:\Code\MyProject\build` and the project in `C:\Code\MyProject\build\MyProject`.

---
title: Using Premake
---

*New to Premake? You might want to start with [What is Premake?](What-Is-Premake.md)*

If you haven't already, you can [download Premake here](/download), or [build it from source](Building-Premake.md). Premake is a small command line executable, delivered as a single file. Just unpack the download and place the executable on your system search path, or anywhere else convenient.

## Using Premake to Generate Project Files

The simplest Premake command is:

```
premake5 [action]
```

Premake defines the following list of actions out of the box; projects may also add their own custom actions.

| Action      | Description                                                   |
|-------------|---------------------------------------------------------------|
| codelite    | CodeLite projects                                             |
| gmake       | Generate GNU Makefiles (including [Cygwin][1] and [MinGW][2]) |
| gmakelegacy | Generate GNU Makefiles (deprecated exporter)                  |
| ninja       | Ninja projects                                                |
| vs2026      | Generate Visual Studio 2026 project files                     |
| vs2022      | Generate Visual Studio 2022 project files                     |
| vs2019      | Generate Visual Studio 2019 project files                     |
| vs2017      | Generate Visual Studio 2017 project files                     |
| vs2015      | Generate Visual Studio 2015 project files                     |
| vs2013      | Generate Visual Studio 2013 project files                     |
| vs2012      | Generate Visual Studio 2012 project files                     |
| vs2010      | Generate Visual Studio 2010 project files                     |
| vs2008      | Generate Visual Studio 2008 project files                     |
| vs2005      | Generate Visual Studio 2005 project files                     |
| xcode4      | XCode projects                                                |

(Premake4 supported some additional actions that haven't yet been ported to this new version; see the [Available Feature Matrix](Feature-Matrix.md) for the whole list.)

To generate Visual Studio 2013 project files, use the command:

```
premake5 vs2013
```

You can see a complete list of the actions and other options supported by a project with the command:

```
premake5 --help
```

## Using the Generated Projects

For toolsets like Visual Studio and Xcode, you can simply load the generated solution or workspace into your IDE and build as you normally would.

If you have generated makefiles, running `make` with no options will build all targets using the default configuration, as set by the project author. To see the list of available configurations, type:

```
make help
```

To build a different configuration, add the **config** argument:

```
make config=release
```

To remove all generated binaries and intermediate files:

```
make clean                 # to clean the default target
make config=release clean  # to clean a different target
```

Premake generated makefiles do not (currently) support a `make install` step. Instead, project owners are encouraged to [add an install action](Command-Line-Arguments.md) to their Premake scripts, which has the advantage of working with any toolset on any platform. You can check for the existence of an install action by viewing the help (run `premake5 --help` in the project directory).

[1]: http://www.cygwin.com/
[2]: http://www.mingw.org/

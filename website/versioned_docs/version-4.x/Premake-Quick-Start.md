---
title: Premake Quick Start
---

*A quick introduction for people who arrived here directly: Premake is a build configuration tool. It reads a description of a software project and generates the files for one of several different toolsets. By using Premake, software developers can save time and support more tools and users.* [Learn More](http://github.com/premake/premake-4.x/wiki).

## Getting Premake ##

If you don't have Premake already, you can [download](http://premake.github.io/download.html) it now.

Premake is a small (around 200K) command line executable, delivered as a single file. Just unpack the download and place the executable on your system search path or anywhere else convenient.

## Using Premake ##

The simplest Premake command is:

```
premake4 [action]
```

Premake defines the following list of actions out of the box which generate project files for a particular toolset. It is also possible to define custom actions.

| Action     | Description                                                         |
|------------|---------------------------------------------------------------------|
| vs2013     | Generate Visual Studio 2013 project files (coming in Premake 4.4)   |
| vs2012     | Generate Visual Studio 2012 project files (coming in Premake 4.4)   |
| vs2010     | Generate Visual Studio 2010 project files                           |
| vs2008     | Generate Visual Studio 2008 project files                           |
| vs2005     | Generate Visual Studio 2005 project files                           |
| vs2003     | Generate Visual Studio 2003 project files                           |
| vs2002     | Generate Visual Studio 2002 project files                           |
| gmake      | Generate GNU Makefiles (including [Cygwin][2] and [MinGW][3])       |
| xcode3     | Generate Apple Xcode 3 project files                                |
| codeblocks | Generate [Code::Blocks][4] project files                            |
| codelite   | Generate [CodeLite][5] project files                                |

You can see a complete list of the actions and other options supported by a project with the command:

```
premake4 --help
```

Once the project files have been generated you can load the solution or workspace into your IDE and build as you normally would.

## Using the Generated Makefiles ##

Running **make** with no options will build all targets using the default configuration. To build a different configuration supply the **config** argument:

```bash
make config=release
```

Most projects provide debug and release configurations; to see the available targets and configurations, type:

```bash
make help
```

Remove all generated binaries and intermediate files with:

```bash
make clean
```

Premake generated makefiles do *not* support a **make install** step. Instead, project owners are encouraged to [add an install action](Command-Line-Arguments.md) to their Premake scripts, which has the advantage of working with any toolset on any platform. You can check for the existence of an install action by viewing the help (run **premake4 --help** in the project directory).

## Next Steps ##

If you are having trouble building your project, start by contacting the project manager. If you are having trouble building or using Premake, [visit our Support page](https://github.com/premake/premake-4.x/wiki/Help) and I'll try to help you out.

To learn how to use Premake for your own software projects see [Scripting With Premake](Scripting-With-Premake.md).

[1]: https://github.com/premake/premake-4.x/wiki/Premake_Quick_Start
[2]: http://www.cygwin.com/
[3]: http://www.mingw.org/
[4]: http://www.codeblocks.org/
[5]: http://codelite.org/

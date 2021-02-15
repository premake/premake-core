---
title: What Is Premake
---

Imagine yourself the owner of an open source software project. Your users are asking for a Visual Studio 2008 solution, but you don't have Visual Studio! Or perhaps you are a cross-platform game developer struggling to keep projects, solutions, and makefiles in sync. Its a common problem for open and cross-platform projects: restrict yourself to a single, potentially sub-optimal build tool — driving away potential contributors — or manually maintain two, three, or more sets of build scripts.

Not working cross-platform? Have you ever been stuck using an old version of Visual Studio because it was too difficult to upgrade the entire team?

Or maybe you just want an easy way to reconfigure your project for different situations or environments, pulling in different source code or libraries, switches and options.

## Enter Premake ##

Premake is a build configuration tool. Describe your C, C++, or C# software project using a [simple, easy to read syntax](A_Sample_Script) and let Premake generate the project files for:

 * Microsoft Visual Studio 2002-2010, including the [Express editions](http://www.microsoft.com/express)
 * GNU Make, including [Cygwin](http://www.cygwin.com/) and [MinGW](http://www.mingw.org/)
 * [Apple Xcode](http://developer.apple.com/tools/xcode/)
 * [Code::Blocks](http://www.codeblocks.org/)
 * [CodeLite](http://codelite.org/)
 * IC#Code [SharpDevelop](http://www.icsharpcode.net/OpenSource/SD/)
 * [MonoDevelop](http://www.monodevelop.com/Main_Page)

Version 4.1 of Premake added [experimental support for cross-compiling](Using Platforms), targeting:

 * 32- and 64-bit builds
 * Mac OS X 32- and 64-bit universal binaries
 * Playstation 3 (Visual Studio and GNU Make)
 * Xbox 360 (Visual Studio only)

Premake allows you to manage your project configuration in one place and still support those pesky IDE-addicted Windows coders and/or cranky Linux command-line junkies. It allows you to generate project files for tools that you do not own. It saves the time that would otherwise be spent manually keeping several different toolsets in sync. And it provides an easy upgrade path as new versions of your favorite tools are released.

In addition to these project generation capabilities, Premake also provides a complete [Lua scripting environment](http://www.lua.org/), enabling the automation of complex configuration tasks, such as setting up new source tree checkouts or creating deployment packages. These scripts will run on any platform, ending batch/shell script duplication.

Premake is a "plain old C" application, distributed as a single executable file. It is small, weighing in at around 200K. It does not require any additional libraries or runtimes to be installed, and should build and run pretty much anywhere. It is currently being tested and used on Windows, Mac OS X, Linux, and other POSIX environments. It uses only a handful of platform dependent routines (directory management, mostly). Adding support for additional toolsets and languages is straightforward. The source code is available under the [BSD License](http://www.opensource.org/licenses/bsd-license.php). The source code is hosted on [GitHub](https://github.com/premake/premake-4.x); file downloads are hosted on [SourceForge](http://sourceforge.net/projects/premake).

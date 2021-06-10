---
title: What is Premake?
---

Premake is a command line utility which reads a scripted definition of a software project and, most commonly, uses it to generate project files for toolsets like Visual Studio, Xcode, or GNU Make.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }

project "MyProject"
   kind "ConsoleApp"
   language "C++"
   files { "**.h", "**.cpp" }

   filter { "configurations:Debug" }
      defines { "DEBUG" }
      symbols "On"

   filter { "configurations:Release" }
      defines { "NDEBUG" }
      optimize "On"
```
*A sample Premake script.*

```
$ premake5 vs2012
Building configurations...
Running action 'vs2012'...
Generating MyWorkspace.sln...
Generating MyProject.vcxproj...
Generating MyProject.vcxproj.user...
Done.
```
*Premake reads the script and generates project scripts.*


## Use Premake To…

* Maximize your potential audience by allowing developers to use the platforms and toolsets they prefer.

* Allow developers to customize the build, and output project files specific to that configuration.

* Keep builds in sync across toolsets by generating project from the Premake scripts on demand.

* Quickly update large codebases with many workspaces and projects: make the change once in your Premake script and then regenerate.

* Create project files for toolsets you don't own.

* Quickly upgrade to newer versions of your chosen toolset.

* Script common configuration and build maintenance tasks.


## Key Features

The current development version of Premake 5.0 can generate C, C++, or C# projects targeting:

* Microsoft Visual Studio 2005-2019
* GNU Make, including Cygwin and MinGW
* Xcode
* Codelite

Previous version of Premake also supported exporting for MonoDevelop and Code::Blocks. We are in the process of bringing these exporters back online for the final release.

Premake 5.0 generated projects can support:

* 32- and 64-bit builds
* Xbox 360 (Visual Studio only)

[Add-on modules](/community/modules) can extend Premake with support for additional languages, frameworks, and toolsets.

In addition to its project generation capabilities, Premake also provides a complete [Lua](http://lua.org/) scripting environment, enabling the automation of complex configuration tasks such as setting up new source tree checkouts or creating deployment packages. These scripts will run on any platform, ending batch/shell script duplication.

Premake is a "plain old C" application, distributed as a single executable file. It is small, weighing in at around 200K. It does not require any additional libraries or runtimes to be installed, and should build and run pretty much anywhere. It is currently being tested and used on Windows, Mac OS X, Linux, and other POSIX environments. It uses only a handful of platform dependent routines (directory management, mostly). Adding support for additional toolsets and languages is straightforward. The source code is available under the BSD License. The source code is hosted right here on GitHub; file downloads are currently hosted on SourceForge.

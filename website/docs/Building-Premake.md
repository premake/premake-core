---
title: Building Premake
---


If you downloaded a prebuilt binary package you can skip this page, which discusses how to build the Premake source code. Jump ahead to one of the next sections to learn how to develop with Premake.

## Using a Source Code Package ##

If you have one of the [official source code packages](/download), you'll find that project files for a variety of toolsets have already been generated for you in the `build/` folder. Find the right set for your platform and toolset and build as you normally would  (i.e. run `make`). The resulting binaries will be placed in the top-level `bin/` folder.

Skip ahead to the next section to learn more about using the source version of Premake.


## Using the Git Code Repository ##

If you are planning to make changes or contribute to Premake, working directly against the source code repository is the way to go. Premake 5's source code is housed [right here on GitHub](https://github.com/premake/premake-core). To get the source code, see the "Clone" options in the sidebar to the right and follow the instructions there.

Once the core source code has been cloned, you can bootstrap your first Premake executable:

```bash
nmake -f Bootstrap.mak windows   # for Windows
make -f Bootstrap.mak osx        # for Mac OS X
make -f Bootstrap.mak linux      # Linux and similar Posix systems
```

If you get an error related to building for an unsupported architecture, you may need to select the architecture manually. E.g. to build for Apple Silicon set `PLATFROM` to `ARM64`.

```bash
make -f Bootstrap.mak osx PLATFORM=ARM64
```

On Windows you can optionally specify the version of Visual Studio to use for the bootstrap by setting `MSDEV`. To successfully compile on Windows with Visual C++ you must run `vcvars32.bat` first. If you don't have Visual C++ as part of your environment variables then you need to use the full path `C:\Program Files (x86)\Microsoft Visual Studio <version>\VC\bin\vcvars32.bat`. It might be easier to create a batch file with the following contents or copy the contents in appveyor.yml.

```bash
call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" # Sets up the necessary environment variables for nmake to run
nmake -f Bootstrap.mak MSDEV=vs2015 windows    # For Windows with Visual Studio 2015.
```

If your system or toolset is not fully supported by the bootstrap Makefile, you will need to create new project files using an existing version of Premake. The easiest way to get one is by [downloading prebuilt binary package](/download). If a binary is not available for your system, or if you would prefer to build one yourself, grab the latest source code package from that same site and follow the steps in **Using a Source Code Package**, above.

Once you have a working Premake available, you can generate the project files for your toolset by running a command like the following in the top-level Premake directory:

```bash
premake5 gmake  # for makefiles
premake5 vs2012 # for a Visual Studio 2012 solution
premake --help  # to see a list of supported toolsets
```

If this is the first time you have built Premake, or if you have made changes to the Lua scripts, you should prepare them to be embedded into the Premake executable.

```
premake5 embed
```

This creates a C file (at src/host/scripts.c) which contains all of the Lua scripts as static string buffers. These then get compiled into the executable, which is how we get away with shipping a single file instead of a whole bunch of scripts.

You should now have a workspace/solution/makefile in the top-level folder, which you can go ahead and build. The resulting binaries will placed into the **bin/** folder.


## Running the Tests ##

Once you have built an executable, you can verify it by running Premake's unit test suites. From the top-level Premake folder, run:

```bash
bin/debug/premake5 test    # or...
bin/release/premake5 test
```

## Runtime Script Loading ##

If you are modifying or extending Premake, you can skip the embedding and compilation steps and run the scripts directly from the disk. This removes the build from the change-build-test cycle and really speeds up development.

If you are running Premake from the top of its own source tree (where its  premake5.lua is located) you will get this behavior automatically. If you are running Premake from some other location, use the --scripts option to provide the path to that top-level folder:

```
bin/release/premake5 --scripts=../path/to/premake test
```

If you find yourself doing this repeatedly, or if you want Premake to be able to find other, custom scripts, you can also set a search path with the PREMAKE_PATH environment variable. Set it just like you would set your system PATH variable.

Once your changes are complete and you are ready to distribute them to others, embed them into the executable and rebuild:

```bash
bin/release/premake5 embed
make config=release   # or via Visual Studio, etc.
```

## Stuck? ##

Give us a shout [in our Discussions area on GitHub](https://github.com/premake/premake-core/discussions) and we'll be glad to help you out.

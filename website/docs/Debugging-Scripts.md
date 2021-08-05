---
title: Debugging Scripts
---

## ZeroBrane Studio

Since Premake's update to 5.3, the only debugger that seems to be able to debug Premake is the free ZeroBrane Studio IDE.

* [Download ZeroBrane Studio](https://studio.zerobrane.com/) and install it
* Compile a [debug build of Premake](Building-Premake.md). Your premake build should have built luasocket.dll, and there is a mobdebug.lua file in the root. Copy both alongside your premake executable to the location where you intend to run premake.
* Run ZeroBrane Studio and in the Project dropdown, select **Start Debugger Server**.
* There's also a Project tab. Right-click the root folder and select **Project Directory > Choose...** to select the root of the premake repository. Open the lua file you want to debug (you can start with _premake_init.lua) and set a breakpoint.
* Run premake with your desired command line and append `--scripts=path_to_premake --debugger` path_to_premake is the root of the repository where src lives. This isn't necessary if you run premake in the same directory as the src folder. If all goes well premake should think for a moment and the debugger should flash indicating that it has broken execution.
* An example command line would be `C:/my_project_folder/premake5.exe vs2015 --scripts=C:/premake_repo/ --debugger`

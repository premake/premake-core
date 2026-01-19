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

## Visual Studio Code

* [Download Visual Studio Code](https://code.visualstudio.com/) and install it
* Install [Local Lua Debugger](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode) plugin
* Add the following text to the top of the premake5.lua file in your project.
```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
	require("lldebugger").start()
end
```
* Create `launch.json` according to the [debugger settings](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations) and modify it as follows.
```json
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "premake_debug",
			"type": "lua-local",
			"request": "launch",
			"cwd": "${workspaceFolder}",
			"program": {
				// path to premake5.exe
				// If you want to debug including premake5.exe internals, use debug build premake5.exe
				"command": "C:/my_project_folder/premake5.exe",
			},
			"args": [
				"vs2022",
				"--verbose",
				// path to root script file
				"--file=${workspaceFolder}/premake5.lua"
			],
		},
	]
}
```
* Open the lua file you want to debug and [set a breakpoint](https://code.visualstudio.com/docs/editor/debugging#_breakpoints).
* Open Debug Console (Press Ctrl+Shift+Y)
* Press F5 key to start debugging.


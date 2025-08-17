Specifies the path to a specific tool executable for a given toolset. This allows overriding the default tool lookup behavior of Premake.

```lua
toolsetpath(toolsetName, toolName, toolPath)
```

### Parameters

`toolsetName`
:   The name of the toolset (e.g., `"gcc"`, `"clang"`, `"msc"`).

`toolName`
:   The name of the tool within the toolset (e.g., `"cc"` for C compiler, `"cxx"` for C++ compiler, `"ld"` for linker, `"ar"` for archiver).

`toolPath`
:   The absolute or relative path to the tool executable.

### Applies To

Project configurations.

### Example

```lua
project "MyProject"
	kind "ConsoleApp"
	language "C++"
	system "Linux"

	configuration "Release"
		toolset "gcc"
		-- Specify a custom path for the GCC C++ compiler
		toolsetpath("gcc", "cxx", "/opt/my_custom_gcc/bin/g++")

	configuration "Debug"
		toolset "clang"
		-- Specify a custom path for the Clang C compiler
		toolsetpath("clang", "cc", "/usr/local/clang-15/bin/clang")
```

In this example, the `toolsetpath` function is used to specify custom paths for the C++ compiler in the "Release" configuration (using GCC) and the C compiler in the "Debug" configuration (using Clang).
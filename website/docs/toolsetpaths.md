Specifies custom paths for tool executables for one or more toolsets using a nested table structure. This field is primarily intended for internal use by Premake modules and actions. **End users should generally prefer using [`toolsetpath`](toolsetpath.md)** for specifying custom tool paths, as it provides a more user-friendly syntax.

```lua
toolsetpaths {
  ["toolsetName"] = {
    ["toolName"] = "toolPath",
    -- ... more tools for this toolset
  },
  -- ... more toolsets
}
```

### Parameters

The `toolsetpaths` field accepts a table where keys are `toolsetName` (the name of the toolset, e.g., `"gcc"`, `"clang"`, `"msc"`) and values are nested tables.

The nested tables have `toolName` (the name of the tool within the toolset, e.g., `"cc"` for C compiler, `"cxx"` for C++ compiler, `"ld"` for linker, `"ar"`) as keys and `toolPath` (the absolute or relative path to the tool executable) as values.

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
		-- Example of using the toolsetpaths field (less common for end users)
		toolsetpaths {
			gcc = {
				cc = "/opt/my_custom_gcc/bin/gcc",
				cxx = "/opt/my_custom_gcc/bin/g++",
				ar = "/opt/my_custom_gcc/bin/ar"
			}
		}

	configuration "Debug"
		toolset "clang"
		-- Prefer using the toolsetpath function for clarity
		toolsetpath("clang", "cc", "/usr/local/clang-15/bin/clang")
		toolsetpath("clang", "ld", "/usr/local/clang-15/bin/ld")
```

In this example, both the `toolsetpaths` field and the `toolsetpath` function are shown. The `toolsetpath` function is the recommended approach for end users.

### See Also ###

* [toolsetpath](toolsetpath.md)

Specifies build flags to modify the compiling or linking process.

```lua
flags { "flag_list" }
```

### Parameters ###

`flag_list` is a list of string flag names; see below for a list of valid flags. The flag values are not case-sensitive. Flags that are not supported by a particular platform or toolset are ignored.

| Flag                  | Description                                                         | Notes |
|-----------------------|---------------------------------------------------------------------|----------------|
| ExcludeFromBuild      | Exclude a source code file from the build, for the current configuration. |
| FatalCompileWarnings  | Treat compiler warnings as errors. Deprecated in Premake 5.0.0-beta4. Use `fatalwarnings` API instead. |
| FatalLinkWarnings     | Treat linker warnings as errors.  Deprecated in Premake 5.0.0-beta4. Use `fatalwarnings` API instead. |
| FatalWarnings         | Treat all warnings as errors; equivalent to FatalCompileWarnings, FatalLinkWarnings.  Deprecated in Premake 5.0.0-beta4. Use `fatalwarnings` API instead. |
| LinkTimeOptimization  | Enable link-time (i.e. whole program) optimizations. Deprecated in Premake 5.0.0-beta4. Use `linktimeoptimization` API instead. |
| Maps                  | Enable Generate Map File for Visual Studio                          |
| MFC                   | Enable support for Microsoft Foundation Classes. Deprecated in Premake 5.0.0-beta4. Use `mfc` API instead. |
| MultiProcessorCompile | Enable Visual Studio to use multiple compiler processes when building. |
| No64BitChecks         | Disable 64-bit portability warnings.                                |
| NoBufferSecurityCheck | Turn off stack protection checks.                                   |
| NoCopyLocal           | Prevent referenced assemblies from being copied to the target directory (C#) |
| NoFramePointer        | Disable the generation of stack frame pointers.                     |
| NoImplicitLink        | Disable Visual Studio's default behavior of automatically linking dependent projects. |
| NoImportLib           | Prevent the generation of an import library for a Windows DLL.      |
| NoIncrementalLink     | Disable support for Visual Studio's incremental linking feature.    |
| NoManifest            | Prevent the generation of a manifest for Windows executables and shared libraries. |
| NoMinimalRebuild      | Disable Visual Studio's [minimal rebuild feature][1].| Visual Studio has deprecated this feature as of vs2015.|
| NoPCH                 | Disable precompiled header support. If not specified, the toolset default behavior will be used. |
| NoRuntimeChecks       | Disable Visual Studio's [default stack frame and uninitialized variable checks][2] on debug builds. |
| OmitDefaultLibrary    | Omit the specification of a runtime library in object files.        |
| RelativeLinks         | Forces the linker to use relative paths to libraries instead of absolute paths. |
| ShadowedVariables     | Warn when a variable, type declaration, or function is shadowed.    |
| UndefinedIdentifiers | Warn if an undefined identifier is evaluated in an #if directive.   |
| WPF                   | Mark the project as using Windows Presentation Framework, rather than WinForms. |
| DebugEnvsDontMerge    | Needs documentation                                                        |
| DebugEnvsInherit      | Needs documentation                                                        |
| Thumb                 | Needs documentation                                                        |

### Applies To ###

Project and file configurations, though not all flags are yet supported for files across all exporters.

### Availability ###

Flags are currently available in Premake 5.0 beta3, but are considered deprecated. Future releases will be deprecating and removing all flags in favor of dedicated APIs.

### Examples ###

```lua
-- Enable link-time (i.e. whole program) optimizations.
flags { "LinkTimeOptimization" }

```

[1]: https://docs.microsoft.com/en-us/cpp/build/reference/gm-enable-minimal-rebuild?view=vs-2017
[2]: http://msdn.microsoft.com/en-us/library/8wtf2dfz.aspx

### See Also ###

* [fatalwarnings](fatalwarnings.md)
* [linktimeoptimization](linktimeoptimization.md)
* [mfc](mfc.md)


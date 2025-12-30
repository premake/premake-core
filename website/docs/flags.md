Specifies build flags to modify the compiling or linking process.

```lua
flags { "flag_list" }
```

### Parameters ###

`flag_list` is a list of string flag names; see below for a list of valid flags. The flag values are not case-sensitive. Flags that are not supported by a particular platform or toolset are ignored.

| Flag                  | Description                                                         | Notes |
|-----------------------|---------------------------------------------------------------------|----------------|
| ExcludeFromBuild      | Exclude a source code file from the build, for the current configuration. |
| FatalCompileWarnings  | Treat compiler warnings as errors. Deprecated in Premake 5.0.0-beta4. Use `fatalwarnings` API instead. | Removed in Premake 5.0.0-beta8 |
| FatalLinkWarnings     | Treat linker warnings as errors.  Deprecated in Premake 5.0.0-beta4. Use `fatalwarnings` API instead. | Removed in Premake 5.0.0-beta8 |
| FatalWarnings         | Treat all warnings as errors; equivalent to FatalCompileWarnings, FatalLinkWarnings.  Deprecated in Premake 5.0.0-beta4. Use `fatalwarnings` API instead. | Removed in Premake 5.0.0-beta8 |
| LinkTimeOptimization  | Enable link-time (i.e. whole program) optimizations. Deprecated in Premake 5.0.0-beta4. Use `linktimeoptimization` API instead. | Removed in Premake 5.0.0-beta8 |
| Maps                  | Enable Generate Map File for Visual Studio. Deprecated in Premake 5.0.0-beta8. Use `mapfile` API instead. |                          |
| MFC                   | Enable support for Microsoft Foundation Classes. Deprecated in Premake 5.0.0-beta4. Use `mfc` API instead. | Removed in Premake 5.0.0-beta8 |
| MultiProcessorCompile | Enable Visual Studio to use multiple compiler processes when building. Deprecated in Premake 5.0.0-beta8. Use `multiprocessorcompile` API instead. |
| No64BitChecks         | Disable 64-bit portability warnings. Deprecated in Premake 5.0.0-beta8. Use `enable64bitchecks` API instead. |
| NoBufferSecurityCheck | Turn off stack protection checks. Deprecated in Premake 5.0.0-beta8. Use `buffersecuritycheck` API instead. |
| NoCopyLocal           | Prevent referenced assemblies from being copied to the target directory (C#). Deprecated in Premake 5.0.0-beta8. Use `allowcopylocal` API instead. |
| NoImplicitLink        | Disable Visual Studio's default behavior of automatically linking dependent projects. Deprecated in Premake 5.0.0-beta8. Use `implicitlink` API instead. |
| NoImportLib           | Prevent the generation of an import library for a Windows DLL. Deprecated in Premake 5.0.0-beta8. Use `useimportlib` API instead. |
| NoIncrementalLink     | Disable support for Visual Studio's incremental linking feature. Deprecated in Premake 5.0.0-beta8. Use `incrementallink` API instead. |
| NoManifest            | Prevent the generation of a manifest for Windows executables and shared libraries. Deprecated in Premake 5.0.0-beta8. Use `manifest` API instead. |
| NoMinimalRebuild      | Disable Visual Studio's [minimal rebuild feature][1]. Deprecated in Premake 5.0.0-beta8. Use `minimalrebuild` API instead. | Visual Studio has deprecated this feature as of vs2015.|
| NoPCH                 | Disable precompiled header support. If not specified, the toolset default behavior will be used. Deprecated in Premake 5.0.0-beta8. Use `enablepch` API instead. |
| NoRuntimeChecks       | Disable Visual Studio's [default stack frame and uninitialized variable checks][2] on debug builds. |
| OmitDefaultLibrary    | Omit the specification of a runtime library in object files. Deprecated in Premake 5.0.0-beta8. Use `nodefaultlib` API instead. |
| RelativeLinks         | Forces the linker to use relative paths to libraries instead of absolute paths. Deprecated in Premake 5.0.0-beta8. Use `userelativelinks` API instead. |
| ShadowedVariables     | Warn when a variable, type declaration, or function is shadowed. Deprecated in Premake 5.0.0-beta8. Use `buildoptions` API instead to add compile warnings. |
| UndefinedIdentifiers | Warn if an undefined identifier is evaluated in an #if directive. Deprecated in Premake 5.0.0-beta8. Use `buildoptions` API instead to add compile warnings. |
| WPF                   | Mark the project as using Windows Presentation Framework, rather than WinForms. Deprecated in Premake 5.0.0-beta8. Use `wpf` API instead. |
| DebugEnvsDontMerge    | Prevent debug environment variables from being merged with system environment. Deprecated in Premake 5.0.0-beta8. Use `debugenvsmerge` API instead. |
| DebugEnvsInherit      | Inherit parent environment variables when using debug environment variables. Deprecated in Premake 5.0.0-beta8. Use `debugenvsinherit` API instead. |

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

* [allowcopylocal](allowcopylocal.md)
* [buffersecuritycheck](buffersecuritycheck.md)
* [copylocal](copylocal.md)
* [debugenvsinherit](debugenvsinherit.md)
* [debugenvsmerge](debugenvsmerge.md)
* [enablepch](enablepch.md)
* [fatalwarnings](fatalwarnings.md)
* [implicitlink](implicitlink.md)
* [incrementallink](incrementallink.md)
* [linktimeoptimization](linktimeoptimization.md)
* [manifest](manifest.md)
* [mapfile](mapfile.md)
* [mfc](mfc.md)
* [minimalrebuild](minimalrebuild.md)
* [multiprocessorcompile](multiprocessorcompile.md)
* [nodefaultlib](nodefaultlib.md)
* [useimportlib](useimportlib.md)
* [userelativelinks](userelativelinks.md)
* [wpf](wpf.md)

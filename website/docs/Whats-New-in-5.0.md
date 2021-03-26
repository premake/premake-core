---
title: What's New in 5.0
---

*We haven't been doing a great job of keeping this up-to-date, but it does still hit the major highlights.*

## Name Changes ##

* The executable is now named **premake5**
* The default project script is now **premake5.lua**; premake4.lua remains as a fallback.

## Flags and Actions ##

* --interactive (open an interactive command prompt)
* vs2012, vs2013, vs2015, vs2019 (Visual Studio 2012, 2013, 2015, 2019)

## Major Features ##

* [Custom Rules](custom-rules) (still experimental)
* [Makefile Projects](makefile-projects)
* [Modules](developing-modules)
* [Per-Configuration File Lists](files)
* [Per-File Configurations](configuration)
* [Per-Project Configurations](configurations-and-platforms)
* [Platforms](configurations-and-platforms)
* [Removes](removing-values)
* [System Scripts](system-scripts)
* [Tokens](tokens)
* [HTTP support](http.download)

## New or Modified Globals ##

* [_MAIN_SCRIPT](_main_script)
* [_MAIN_SCRIPT_DIR](_main_script_dir)
* [_PREMAKE_DIR](_premake_dir)

## New or Modified API calls ##

* [architecture](architecture) (new)
* [buildaction](buildaction) (new values)
* [buildcommands](buildcommands) (new)
* [builddependencies](builddependencies) (new)
* [buildlog](buildlog) (new)
* [buildmessage](buildmessage) (new)
* [buildoutputs](buildoutputs) (new)
* [characterset](characterset) (new)
* [callingconvention](callingconvention) (new)
* [cleancommands](cleancommands) (new)
* [cleanextensions](cleanextensions) (new)
* [clr](clr) (new, replaces flags `Managed` and `Unsafe`)
* [configfile](configfile) (new)
* [configmap](configmap) (new)
* [configuration](configuration) (retired)
* [configurations](configurations) (modified)
* [copylocal](copylocal) (new)
* [debugcommand](debugcommand) (new)
* [debugconnectcommands](debugconnectcommands) (new)
* [debugextendedprotocol](debugextendedprotocol) (new)
* [debugport](debugport) (new)
* [debugremotehost](debugremotehost) (new)
* [debugsearchpaths](debugsearchpaths) (new)
* [debugstartupcommands](debugstartupcommands) (new)
* [dependson](dependson) (new)
* [disablewarnings](disablewarnings) (new)
* [dotnetframework](dotnetframework) (new)
* [editandcontinue](editandcontinue) (new, replaces flag `NoEditAndContinue`)
* [editorintegration](editorintegration) (new)
* [enablewarnings](enablewarnings) (new)
* [endian](endian) (new)
* [entrypoint](entrypoint) (new)
* [exceptionhandling](exceptionhandling) (new)
* [external](external) (new)
* [externalproject](externalproject) (new)
* [externalrule](externalrule) (new)
* [fatalwarnings](fatalwarnings) (new)
* [fileextension](fileextension) (new)
* [filename](filename) (new)
* [filter](filter) (new)
* [flags](flags) (new values)
* [floatingpoint](floatingpoint) (new, replaces flags `FloatFast` and `FloatStrict`)
* [forceincludes](forceincludes) (new)
* [forceusings](forceusings) (new)
* [fpu](fpu) (new)
* [gccprefix](gccprefix) (new)
* [group](group) (new)
* [icon](icon) (new)
* [inlining](inlining) (new)
* [kind](kind) (Makefile, None)
* [linkbuildoutputs](linkbuildoutputs) (new)
* [links](links)
* [language](language) (new values)
* [locale](locale) (new)
* [makesettings](makesettings) (new)
* [namespace](namespace) (new)
* [nativewchar](nativewchar) (new, replaces flag `NativeWChar`)
* [newaction](newaction) (modified)
* [nuget](nuget) (new)
* [objdir](objdir) (modified)
* [optimize](optimize) (new, replaces flags `OptimizeSize` and `OptimizeSpeed`)
* [pic](pic) (new)
* [platforms](platforms) (modified)
* [postbuildmessage](postbuildmessage) (new)
* [prebuildmessage](prebuildmessage) (new)
* [prelinkmessage](prelinkmessage) (new)
* [project](project) (modified)
* [propertydefinition](propertydefinition) (new)
* [rebuildcommands](rebuildcommands) (new)
* [rtti](rtti) (new, replaces flag `NoRTTI`)
* [rule](rule) (new)
* [rules](rules) (new)
* [runtime](runtime) (new)
* [solution](workspace) (name changed)
* [startproject](startproject) (new)
* [strictaliasing](strictaliasing) (new)
* [sysincludedirs](sysincludedirs) (new)
* [syslibdirs](syslibdirs) (new)
* [system](system) (new)
* [toolset](toolset) (new)
* [undefines](undefines) (new)
* [vectorextensions](vectorextensions) (new, replaces flags `EnableSSE` and `EnableSSE2`)
* [warnings](warnings) (new, replaces flags `ExtraWarnings` and `NoWarnings`)
* [workspace](workspace) (new)

## New or Modified Lua library calls ##

* [includeexternal](includeexternal) (new)
* [require](require) (modified)

* [debug.prompt](debug.prompt) (new)

* [http.download](http.download) (new)
* [http.get](http.get) (new)

* [os.chmod](os.chmod) (new)
* [os.islink](os.islink) (new)
* [os.realpath](os.realpath) (new)
* [os.uuid](os.uuid) (can now generated deterministic name-based UUIDs)

* [path.getabsolute](path.getabsolute) (new "relative to" argument)

* [string.hash](string.hash) (new)

## Deprecated Values and Functions ##

* [buildrule](buildrule)
* [flags](flags):
	* Component
	* EnableSSE, EnableSSE2: use [vectorextensions](vectorextensions) instead
	* ExtraWarnings, NoWarnings: use [warnings](warnings) instead
	* FloatFast, FloatStrict: use [floatingpoint](floatingpoint) instead
	* Managed, Unsafe: use [clr](clr) instead
	* NativeWChar: use [nativewchar](nativewchar) instead
	* NoEditAndContinue: use [editandcontinue](editandcontinue) instead
	* NoRTTI: use [rtti](rtti) instead.
	* OptimizeSize, OptimizeSpeed: use [optimize](optimize) instead

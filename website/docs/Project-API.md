### Core APIs ###

| API                                                       | Brief              |
|-----------------------------------------------------------|--------------------|
| [_ACTION](_ACTION)                                        | The action that will be run |
| [_ARGS](_ARGS)                                            | Array of action args |
| [_MAIN_SCRIPT](_MAIN_SCRIPT)                              |  |
| [_MAIN_SCRIPT_DIR](_MAIN_SCRIPT_DIR)                      |  |
| [_OPTIONS](_OPTIONS)                                      |  |
| [_OS](_OS)                                                | The currently targeted operating system |
| [_PREMAKE_COMMAND](_PREMAKE_COMMAND)                      |  |
| [_PREMAKE_DIR](_PREMAKE_DIR)                              |  |
| [_PREMAKE_VERSION](_PREMAKE_VERSION)                      | The version of the currently executing instance of Premake |
| [_WORKING_DIR](_WORKING_DIR)                              |  |
| [architecture](architecture)                              |  |
| [atl](atl)                                                | Use Microsoft's Active Template Library |
| [basedir](basedir)                                        |  |
| [bindirs](bindirs)                                        |  |
| [buildaction](buildaction)                                |  |
| [buildcommands](buildcommands)                            |  |
| [buildcustomizations](buildcustomizations)                |  |
| [builddependencies](builddependencies)                    |  |
| [buildinputs](buildinputs)                                |  |
| [buildlog](buildlog)                                      |  |
| [buildmessage](buildmessage)                              |  |
| [buildoptions](buildoptions)                              | Additional build options (passed directly to compiler) |
| [buildoutputs](buildoutputs)                              |  |
| [buildrule](buildrule)                                    |  |
| [callingconvention](callingconvention)                    | Sets the function calling convention |
| [cdialect](cdialect)                                      |  |
| [characterset](characterset)                              | Set the character encoding |
| [cleancommands](cleancommands)                            |  |
| [cleanextensions](cleanextensions)                        |  |
| [clr](clr)                                                | Use Microsoft's Common Language Runtime |
| [compileas](compileas)                                    |  |
| [compilebuildoutputs](compilebuildoutputs)                |  |
| [configfile](configfile)                                  |  |
| [configmap](configmap)                                    |  |
| [configuration](configuration)                            |  |
| [configurations](configurations)                          |  |
| [copylocal](copylocal)                                    |  |
| [cppdialect](cppdialect)                                  |  |
| [customtoolnamespace](customtoolnamespace)                |  |
| [debugargs](debugargs)                                    |  |
| [debugcommand](debugcommand)                              |  |
| [debugconnectcommands](debugconnectcommands)              | Debugger commands to execute on remote target connection |
| [debugconstants](debugconstants)                          |  |
| [debugdir](debugdir)                                      | Working directory for debug session |
| [debugenvs](debugenvs)                                    | Env vars for debug session |
| [debugextendedprotocol](debugextendedprotocol)            | Use gdb 'extended' protocol; maintain a persistent connection |
| [debugformat](debugformat)                                | Format for embedded debug information |
| [debugger](debugger)                                      |  |
| [debuggertype](debuggertype)                              |  |
| [debuglevel](debuglevel)                                  |  |
| [debugpathmap](debugpathmap)                              |  |
| [debugport](debugport)                                    | Port to use for remote debugging |
| [debugremotehost](debugremotehost)                        | Target for remote debugging |
| [debugsearchpaths](debugsearchpaths)                      | Search paths for source code while debugging |
| [debugstartupcommands](debugstartupcommands)              | Debugger commands to execute on debugger startup |
| [debugtoolargs](debugtoolargs)                            |  |
| [debugtoolcommand](debugtoolcommand)                      |  |
| [defaultplatform](defaultplatform)                        |  |
| [defaultplatform](defaultplatform)                        |  |
| [defines](defines)                                        |  |
| [dependson](dependson)                                    |  |
| [deploymentoptions](deploymentoptions)                    |  |
| [disablewarnings](disablewarnings)                        |  |
| [display](display)                                        |  |
| [display](display)                                        |  |
| [docdir](docdir)                                          |  |
| [docname](docname)                                        |  |
| [editandcontinue](editandcontinue)                        |  |
| [editorintegration](editorintegration)                    | Enable or disable IDE integration |
| [enablewarnings](enablewarnings)                          |  |
| [endian](endian)                                          |  |
| [entrypoint](entrypoint)                                  | Specify the program entry point function |
| [exceptionhandling](exceptionhandling)                    | Enable or disable exception handling |
| [external](external)                                      |  |
| [externalRule](externalRule)                              |  |
| [fatalwarnings](fatalwarnings)                            |  |
| [fileextension](fileextension)                            |  |
| [filename](filename)                                      |  |
| [files](files)                                            |  |
| [filter](filter)                                          |  |
| [flags](flags)                                            |  |
| [floatingpoint](floatingpoint)                            |  |
| [floatingpointexceptions](floatingpointexceptions)        |  |
| [forceincludes](forceincludes)                            |  |
| [forceusings](forceusings)                                |  |
| [fpu](fpu)                                                |  |
| [framework](framework)                                    |  |
| [functionlevellinking](functionlevellinking)              |  |
| [gccprefix](gccprefix)                                    |  |
| [group](group)                                            |  |
| [headerdir](headerdir)                                    |  |
| [headername](headername)                                  |  |
| [icon](icon)                                              |  |
| [ignoredefaultlibraries](ignoredefaultlibraries)          | Specify a list of default libraries to ignore |
| [imageoptions](imageoptions)                              |  |
| [imagepath](imagepath)                                    |  |
| [implibdir](implibdir)                                    |  |
| [implibextension](implibextension)                        |  |
| [implibname](implibname)                                  |  |
| [implibprefix](implibprefix)                              |  |
| [implibsuffix](implibsuffix)                              |  |
| [include](include)                                        |  |
| [includedirs](includedirs)                                |  |
| [includeexternal](includeexternal)                        |  |
| [inlining](inlining)                                      | Tells the compiler when it should inline functions |
| [intrinsics](intrinsics)                                  |  |
| [kind](kind)                                              |  |
| [language](language)                                      |  |
| [largeaddressaware](largeaddressaware)                    |  |
| [libdirs](libdirs)                                        |  |
| [linkbuildoutputs](linkbuildoutputs)                      |  |
| [linkgroups](linkgroups)                                  | Turn on/off linkgroups for gcc/clang |
| [linkoptions](linkoptions)                                | Additional linker options (passed directly to linker) |
| [links](links)                                            |  |
| [locale](locale)                                          |  |
| [location](location)                                      | Specifies the directory for the generated workspace/project file |
| [makesettings](makesettings)                              |  |
| [namespace](namespace)                                    |  |
| [nativewchar](nativewchar)                                |  |
| [nuget](nuget)                                            |  |
| [nugetsource](nugetsource)                                |  |
| [objdir](objdir)                                          | Output dir for object/intermediate files |
| [optimize](optimize)                                      | Optimization level |
| [pchheader](pchheader)                                    | Precompiled header file |
| [pchsource](pchsource)                                    | Precompiled header source file (which should build the PCH) |
| [pic](pic)                                                | Position independent code |
| [platforms](platforms)                                    |  |
| [postbuildcommands](postbuildcommands)                    |  |
| [postbuildmessage](postbuildmessage)                      |  |
| [prebuildcommands](prebuildcommands)                      |  |
| [prebuildmessage](prebuildmessage)                        |  |
| [preferredtoolarchitecture](preferredtoolarchitecture)    |  |
| [prelinkcommands](prelinkcommands)                        |  |
| [prelinkmessage](prelinkmessage)                          |  |
| [project](project)                                        |  |
| [propertydefinition](propertydefinition)                  |  |
| [rebuildcommands](rebuildcommands)                        |  |
| [resdefines](resdefines)                                  |  |
| [resincludedirs](resincludedirs)                          |  |
| [resoptions](resoptions)                                  |  |
| [resourcegenerator](resourcegenerator)                    |  |
| [rtti](rtti)                                              | Enable or disable runtime type information |
| [rule](rule)                                              |  |
| [rules](rules)                                            |  |
| [runtime](runtime)                                        |  |
| [sharedlibtype](sharedlibtype)                            |  |
| [startproject](startproject)                              |  |
| [strictaliasing](strictaliasing)                          |  |
| [stringpooling](stringpooling)                            |  |
| [symbols](symbols)                                        | Turn symbol generation on/off |
| [symbolspath](symbolspath)                                | Allows you to specify the target location of the symbols |
| [sysincludedirs](sysincludedirs)                          |  |
| [syslibdirs](syslibdirs)                                  |  |
| [system](system)                                          |  |
| [tags](tags)                                              |  |
| [targetdir](targetdir)                                    |  |
| [targetextension](targetextension)                        |  |
| [targetname](targetname)                                  |  |
| [targetprefix](targetprefix)                              |  |
| [targetsuffix](targetsuffix)                              |  |
| [toolset](toolset)                                        |  |
| [undefines](undefines)                                    |  |
| [usingdirs](usingdirs)                                    |  |
| [uuid](uuid)                                              | Set project GUID (for VS projects/workspaces) |
| [vectorextensions](vectorextensions)                      | Enable hardware vector extensions |
| [versionconstants](versionconstants)                      |  |
| [versionlevel](versionlevel)                              |  |
| [vpaths](vpaths)                                          |  |
| [warnings](warnings)                                      |  |
| [workspace](workspace)                                    |  |

### Builtin Extension APIs ###

The following API reference is for use with various built-in extensions.

| D language APIs                                | Brief              |
|------------------------------------------------|--------------------|
| [debugconstants](https://github.com/premake/premake-dlang/wiki/debugconstants)     | Declare debug identifiers |
| [debuglevel](https://github.com/premake/premake-dlang/wiki/debuglevel)             | Declare debug level |
| [docdir](https://github.com/premake/premake-dlang/wiki/docdir)                     | Output dir for ddoc generation |
| [docname](https://github.com/premake/premake-dlang/wiki/docname)                   | Filename for the ddoc output |
| [headerdir](https://github.com/premake/premake-dlang/wiki/headerdir)               | Output dir for interface file generation |
| [headername](https://github.com/premake/premake-dlang/wiki/headername)             | Filename for the interface (.di) file |
| [versionconstants](https://github.com/premake/premake-dlang/wiki/versionconstants) | Declare version identifiers |
| [versionlevel](https://github.com/premake/premake-dlang/wiki/versionlevel)         | Declare version level |

| Xcode APIs                                     | Brief              |
|------------------------------------------------|--------------------|
| [xcodebuildsettings](xcodebuildsettings)       |  |
| [xcodebuildresources](xcodebuildresources)     |  |

Provides a way to reference projects that were created manually, or outside of Premake.

```lua
externalproject ("project")
```

The `externalproject()` function behaves the same as [project()](project.md), taking a name argument that is used as the project's file name.

### Parameters ###

`project` is name of the project. If no explicit filename is provided (using [filename](filename.md)) the appropriate file extension will be added for the current action: ".vcproj" for Visual Studio 2008, ".vcxproj" for Visual Studio 2010, etc.

### Availability ###

Premake 5.0.0-alpha1 or later for Visual Studio.

### Examples ###

```lua
externalproject "MyExternalProject"
   location "build/MyExternalProject"
   uuid "57940020-8E99-AEB6-271F-61E0F7F6B73B"
   kind "StaticLib"
   language "C++"
```

The calls to uuid(), kind(), and language() are mandatory; this information is needed to properly assemble the Premake-generated workspace. The call to location() is optional and used to locate the directory containing the external project file.

The external project file does not need to exist at the time the workspace is generated.

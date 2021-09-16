Specifies a list of libraries and projects to link against.

```lua
links { "references" }
```

### Parameters ###

`references` is a list of library and project names.

When linking against another project in the same workspace, specify the project name here, rather than the library name. Premake will figure out the correct library to link against for the current configuration, and will also create a dependency between the projects to ensure a proper build order.

When linking against system libraries, do not include any prefix or file extension. Premake will use the appropriate naming conventions for the current platform. With two exceptions:

* Managed C++ projects can link against managed assemblies by explicitly specifying the ".dll" file extension. Unmanaged libraries should continue to be specified without any decoration.

* Objective C frameworks can be linked by explicitly including the ".framework" file extension.

* For Visual Studio, this will add the specified project into References.  In contrast, 'dependson' generates a build order dependency in the solution between two projects.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

Link against some system libraries.

```lua
filter { "system:windows" }
   links { "user32", "gdi32" }

filter { "system:linux" }
   links { "m", "png" }

filter { "system:macosx" }
   -- OS X frameworks need the extension to be handled properly
   links { "Cocoa.framework", "png" }
  ```

  In a workspace with two projects, link the library into the executable. Note that the project name is used to specify the link; Premake will automatically figure out the correct library file name and directory and create a project dependency.

  ```lua
  workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   language "C++"

   project "MyExecutable"
      kind "ConsoleApp"
      files "**.cpp"
      links { "MyLibrary" }

   project "MyLibrary"
      kind "SharedLib"
      files "**.cpp"
```

You may also create links between non-library projects. In this case, Premake will generate a build dependency (the linked project will build first), but not an actual link. In this example, MyProject uses a build dependency to ensure that MyTool gets built first. It then uses MyTool as part of its build process.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   language "C++"

   project "MyProject"
      kind "ConsoleApp"
      files "**.cpp"
      links { "MyTool" }
      prebuildcommands { "MyTool --dosomething" }

   project "MyTool"
      kind "ConsoleApp"
      files "**.cpp"
```

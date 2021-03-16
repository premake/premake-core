Sets the [Universally Unique Identifier](http://en.wikipedia.org/wiki/UUID) (UUID) for a project.

```lua
uuid ("project_uuid")
```

UUIDs are synonymous (for Premake's purposes) with [Globally Unique Identifiers](http://en.wikipedia.org/wiki/Globally_Unique_Identifier) (GUID).

Premake automatically assigns a UUID to each project, which is used by the Visual Studio generators to identify the project within a workspace. This UUID is essentially random and will change each time the project file is generated. If you are storing the generated Visual Studio project files in a version control system, this will create a lot of unnecessary deltas. Using the `uuid` function, you can assign a fixed UUID to each project which never changes, removing the randomness from the generated projects.

### Parameters ###

`project_uuid` is the UUID for the current project. It should take the form "01234567-ABCD-ABCD-ABCD-0123456789AB" (see the examples below for some real UUID values). You can use the Visual Studio [guidgen](http://msdn2.microsoft.com/en-us/library/ms241442(VS.80).aspx) tool to create new UUIDs, or [this website](http://www.famkruithof.net/uuid/uuidgen), or run Premake once to generate Visual Studio files and copy the assigned UUIDs.

### Applies To ###

Projects.

### Return Value ###

The current project UUID, or nil if no UUID has been set.

### Availability ###

Premake 4.0 or later.

### Examples ###

Set the UUID for a current project.

```lua
uuid "BE2461B7-236F-4278-81D3-F0D476F9A4C0"
```

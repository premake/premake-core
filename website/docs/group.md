Starts a "workspace group", a virtual folder to contain one or more projects.

```lua
group("name")
```

### Parameters ###

`name` is the name of the virtual folder, as it should appear in the IDE. Nested groups may be created by separating the names with forward slashes.

### Applies To ###

Workspaces.

### Availability ###

5.0 or later.

### Examples ###

```lua
workspace "MyWorkspace"

-- put the projects "Tests1" and "Tests2" in a virtual folder named "Tests"

group "Tests"

    project "Tests1"
      -- Tests1 stuff goes here

   project "Tests2"
      -- Tests2 stuff goes here

-- Any project defined after the call to group() will go into that group. The
-- project can be defined in a different script though.

group "Tests"

    include "tests/tests1"
    include "tests/tests2"

-- Groups can be nested with forward slashes, like a file path.

group "Tests/Unit"

-- To "close" a group and put projects back at the root level use
-- an empty string for the name.

group ""

   project "TestHarness"
```

The group value is latched the first time a project is declared but it can be overriden later:

```lua
local prj = project "Tests1"
prj.group = "NotActuallyATest"
```

or

```lua
project("Tests1").group = "NotActuallyATest"
```
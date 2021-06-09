---
title: Scopes & Inheritance
---

As you may have noticed from the previous samples, Premake uses a pseudo-declarative syntax for specifying project information. You specify a *scope* (i.e. a workspace or project) for the settings, and then the settings to be placed in that scope.

Scopes have a hierarchy: a *global* scope containing workspaces, which in turn contains projects. Values placed into the outer scopes are inherited by the inner ones, so workspaces inherit the values stored at the global scope, and projects inherit values stored in workspaces.

```lua
-- global scope, all workspaces will receive these values
defines { "GLOBAL" }

workspace "MyWorkspaces"
  -- workspace scope inherits the global scope; the list value
  -- will now be { "GLOBAL", "WORKSPACE" }
  defines { "WORKSPACE" }

project "MyProject"
  -- project scope inherits from its workspace; the list value
  -- will now be { "GLOBAL", "WORKSPACE", "PROJECT" }
  defines { "PROJECT" }
```

Sometimes it can be helpful to go back and add values to a previously declared scope. You can do this the same way you declared it in the first place: by calling [`workspace`](workspace.md) or [`project`](project.md), using the same name.

```lua
-- declare my workspace
workspace "MyWorkspace"
  defines { "WORKSPACE1" }

-- declare a project or two
project "MyProject"
  defines { "PROJECT" }

-- re-select my workspace to add more settings, which will be inherited
-- by all projects in the workspace
workspace "MyWorkspace"
  defines { "WORKSPACE2" }  -- value is now { "WORKSPACE1", "WORKSPACE2" }
```

You can also select the parent or container of the current scope without having to know its name by using the special "*" name.

```lua
-- declare my workspace
workspace "MyWorkspace"
  defines { "WORKSPACE1" }

-- declare a project or two
project "MyProject"
  defines { "PROJECT" }

-- re-select my workspace to add more settings
project "*"
  defines { "WORKSPACE2" }  -- value is now { "WORKSPACE1", "WORKSPACE2" }

-- re-select the global scope
workspace "*"
```

Think of the "*" as a wilcard meaning "all projects in my parent container" or "all workspaces in the global scope".

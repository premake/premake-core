---
title: Embedding Modules
---

*This section only applies if you want to embed your module into a custom build of Premake for easier distribution. If you're not doing that, you can skip it.*

Premake includes a number of modules as part of the official builds, with more being added regularly. These modules are embedded directly into Premake along with the core scripts to enable easy distribution of a single, self-contained executable.

If you are creating a custom build of Premake, you can easily embed your own modules by following the instructions below. Also take a look at Premake's own set of modules in the `modules/` folder for some real working examples.

#### 1. Put your module where Premake can find it.

Premake's embedding system only considers scripts which are in Premake source code tree, so the first step is to put your module where it can be found. Premake's own modules are stored in the `modules/` folder.

#### 2. Add a manifest

Premake needs to know which scripts it should embed, and which it should ignore (tests, etc.). Create a file named `_manifest.lua` which returns an array file names to be loaded. For example, Premake's Xcode module manifest looks like this:

```lua
return {
    "_preload.lua",
    "xcode.lua",
    "xcode4_workspace.lua",
    "xcode_common.lua",
    "xcode_project.lua",
}
```

#### 3. Add an (optional) preload script

As more modules get added, Premake has to do more and more work on startup to evaluate all of those script files. To help minimize that work, modules should try to defer loading until they are actually needed by the project being generated.

On startup, Premake will check each embedded module for script named `_preload.lua`. If present, Premake will run that script, and defer loading the rest of the module. After the project script has had a chance to run, Premake will then ask the module if it needs to be loaded and, if so, load it before continuing. If no `_preload.lua` script is present, the module will be fully loaded immediately on startup.

To enable this, create a file named `_preload.lua` (be sure to also add it to your manifest). Move any settings or values that might be required by a project script—new actions, command line options, or project API calls or allowed values—out of your module to this file. At the very end of the script, return a function which determines whether the module can be loaded or not.

Here is a subset of the `_preload.lua` script from Premake's Xcode module:

```lua
    local p = premake

-- Register the Xcode action.

    newaction {
        trigger     = "xcode4",
        shortname   = "Apple Xcode 4",
        description = "Generate Apple Xcode 4 project files",

        -- …
    }

-- Decide when the full module should be loaded.

    return function(cfg)
        return (_ACTION == "xcode4")
    end
```

It starts by registering the Xcode action; this allows the action to be used on the command line and appear in Premake's help text, even though the full module has not yet been loaded. It then returns a test function to decide when the module should be loaded: in this case, when the user requests the "xcode4" action on the command line.

In the case of a new action, the test function's configuration argument is ignored. In Premake's D language module, it should only load if one of the project's specified in the user scripts wants to use the D language.

```lua
return function(cfg)
    return (cfg.language == "D")
end
```

#### 4. Tell Premake to load your module

If you would like your module loaded (or pre-loaded) on startup, you must add it to the list in `src/_modules.lua`. Modules in this list can be used by project scripts without having to first `require()` them.

Modules that are not in this list are still embedded and may still be used by calling `require()`.

#### 5. Embed and rebuild

The final step is run Premake's embedding script (`premake5 embed`) and then rebuild the Premake executable.

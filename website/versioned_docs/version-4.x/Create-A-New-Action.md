---
title: Create A New Action
---

An *action* is what gets triggered when you run Premake; the command `premake4 vs2008` triggers the Visual Studio 2008 action, while `premake4 clean` triggers the clean action.

I created an example action, available in the source code packages at `src/actions/example`, to help you get started. This example writes out simple *solution* and *project* files, showing how to get out the project information using the Premake APIs. The tutorial below will show you how to use these example files to get started on your own actions.

## Setting Up ##

I keep all of the actions in `src/actions`, so create a new folder there with an appropriate name. Look at the other folders at that location, you'll get the idea.

Copy the files from `src/actions/example` to your new folder and rename them appropriately. The leading underscore on `_example.lua` is optional; it is a convention I use to indicate which file contains the action description (more on that below). The underscore sorts this file to the top of the list making it easy to locate. Files without the leading underscore contain the actual implementation of the action.

I'll continue to use the original file names (like `_example.lua`) through this explanation. Substitute in your new names.

Add your new files (and any others you create later) to the script manifest at `src/_manifest.lua`.

```lua
-- The master list of built-in scripts. Order is important! If you want to
-- build a new script into Premake, add it to this list.

    return
    {
        -- core files
        "base/os.lua",
        "base/path.lua",

        "...and so on...",

        -- Clean action
        "actions/clean/_clean.lua",

        -- Your new action goes here
        "actions/example/_example.lua",
        "actions/example/example_solution.lua",
        "actions/example/example_project.lua",
    }
```

Order matters a little here: `_example.lua` defines the namespace for the action and must appear first. See the comments in that file for more information.

## Start coding ##

I've loaded up the example files, particularly the action description, to help you make sense of them. Rather than repeating all of that here, I'll just let you go browse through the files and start plugging in the code for your own actions.

If you get stuck, if something isn't clear, or you want to see a demonstration of something that isn't covered by the example [drop a note in the forums](https://groups.google.com/forum/#!forum/premake-development) and I'll try to help you out.

---
title: Filters
---

Premake's filter system allows you target build settings to the exact configurations in which you want them to appear. You can filter by specific build configurations or platforms, operating system, target actions, [and more](filter.md).

Here is an example which sets a preprocessor symbol named "DEBUG" in a workspace's "Debug" build configuration, and "NDEBUG" in the Release configuration.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }

   filter "configurations:Debug"
      defines { "DEBUG" }

   filter "configurations:Release"
      defines { "NDEBUG" }
```

Filters are always made up of two parts: a *prefix* that specifies which field is being filtered against, and a *pattern* that specifies which values of that field should be accepted. Here is another example that filters by the target action:

Filters follow Premake's pseudo-declarative style for its scripts: calling filter() makes that filter condition "active". All settings which subsequently appear in the script will be filtered by this condition until a new filter or container (workspace, project) is activated.

```lua
-- All of these settings will appear in the Debug configuration
filter "configurations:Debug"
  defines { "DEBUG" }
  flags { "Symbols" }

-- All of these settings will appear in the Release configuration
filter "configurations:Release"
  defines { "NDEBUG" }
  optimize "On"

-- This is a sneaky bug (assuming you always want to link against these lib files).
-- Because the last filter set was Release. These libraries will only be linked for release.
-- To fix this place this after the "Deactivate" filter call below. Or before any filter calls.
links { "png", "zlib" }

-- "Deactivate" the current filter; these settings will apply
-- to the entire workspace or project (whichever is active)
filter {}
  files { "**.cpp" }
```

Filters are evaluated at generation time, when the workspace or project file is being created and written to disk. When it comes time to output the settings for this workspace's "Debug" build configuration, Premake evaluates the list of filters to find those that match the "Debug" criteria.

Using the above example, Premake would first consider the filter "configurations:Debug". It would check the name of the configuration that was currently being output, see that it matched, and so include any settings up to the next filter call.

The filter "configurations:Release" would be skipped, because the pattern "Release" would not match the name of the configuration currently being generated ("Debug").

The last filter "{}" does not define any filtering criteria, and so does not exclude anything. Any settings applied after this filter will appear in _all_ configurations within the workspace or project.

Filters may also be combined, modified with "or" or "not", and use pattern matches. For a more complete description and lots of examples, see [`filter`](filter.md).

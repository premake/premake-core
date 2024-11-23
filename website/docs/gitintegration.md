Enable git integration to run premake on checkout.

```lua
gitintegration ("value")
```

### Parameters ###

| Action          | Description                                                                      |
|-----------------|----------------------------------------------------------------------------------|
| Off             | Disable git integration.                                                         |
| Always          | Run premake on checkout.                                                         |
| OnNewFiles      | Run premake only when files are added/removed or if premake script has changed.  |

### Applies To ###

Global scope.

### Availability ###

Premake 5.0.0 beta 3 or later.

### Examples ###

Regenerate autoversion.h with git tag when checkout to another branch.

```lua
gitintegration "Always"

local locationDir = _OPTIONS["to"]

local function autoversion_h()
	local git_tag, errorCode = os.outputof("git describe --tag --always")
	if errorCode == 0 then
		print("git description: ", git_tag)
		local content = io.readfile("src/autoversion.h.in")
		content = content:gsub("${GIT_DESC}", git_tag)

		os.mkdir(locationDir)
		local f, err = os.writefile_ifnotequal(content, path.join(locationDir, "autoversion.h"))

		if (f == 0) then -- file not modified
		elseif (f < 0) then
			error(err, 0)
			return false
		elseif (f > 0) then
			print("Generated autoversion.h...")
		end

		return true
	else
		print("`git describe --tag` failed with error code", errorCode, git_tag)
		return false
	end
end

local have_autoversion_h = autoversion_h()

workspace "MyProject"
	location(locationDir)

	if have_autoversion_h then
		includedirs { locationDir } -- for generated file (autoversion.h)
	end
  -- [..]
```

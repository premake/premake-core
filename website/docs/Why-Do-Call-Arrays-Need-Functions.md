---
title: Why Do Call Arrays Need Functions?
---

*"Hang on a minute,"* you're now thinking. *"Why do I need to override a function, call it to get the table, and then insert my new call? Why don't you just have a global table? Then I could insert my new call and skip that override business."*

In other words, why couldn't the list of functions look like this instead?

```lua
m.elements.project = {
	m.xmlDeclaration,
	m.project,
	m.projectConfigurations,
	-- and so on...
}

-- then I could do this:

table.insertafter(m.elements.project, m.xmlDeclaration, myNewFunction)

-- instead of this!

premake.override(m.elements, "project", function(base, prj)
	local calls = base(prj)
	table.insertafter(calls, m.xmlDeclaration, myNewFunction)
	return calls
end)
```

The answer: that would break the ability to override the functions in the array. Let me explain...

The functions being included in the array are resolved at the time the code is evaluated. For a global table that means at the time the script is first loaded and executed.

When the code is executed, `m.project` (perhaps better thought of here as `m["project"]`) is evaluated and *the function it represents* is stored into the array. Kind of like this:

```lua
m.elements.project = {
	function: 0x10017b280
	function: 0x100124dd0
	function: 0x10017b2c0
	-- and so on...

}
```

That's all well and good: `m.project` evaluates to `function: 0x100124dd0` and that's what is in the array.

Now what happens if want to override `m.project`?

```lua
premake.override(m, "project", function(base, prj)
	print("All your base are belong to us")
	base(prj)
end)
```

`premake.override()` takes your new replacement function and assigns it to `m.project` (or `m["project"]` if that's easier to visualize). Which means the symbol `m.project` now evaluates to a different function, say `function: 0x100300360`.

If you call `m.project(prj)` directly, your replacement function will be executed as expected. However, since the `m.elements.project` table has already been evaluated, it still points to the original `function: 0x100124dd0`. Which means that when the Visual Studio project is generated and that call array is processed, your override will be ignored.

So getting to the point: by putting the call array table inside a function, we defer evaluation *until the function is actually called*. Since all of the user scripts are called before the Visual Studio project is generated, your override will already be in place, `m.project` will evaluate to your replacement function (`function: 0x100300360` instead of `function: 0x100124dd0`), and the correct code will be run.

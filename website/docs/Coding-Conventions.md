---
title: Coding Conventions
---

While not all of Premake's code currently follows these conventions, we are gradually nudging everything in this direction and hope to have it all done before the final 5.0 release. Knowing these conventions will make the code a little easier to read and follow.


### Tables as Namespaces

Premake tables are used as namespaces, with related functions grouped together into their own namespace table. Most of Premake's own code is placed into a table named `premake`. Code related to the project scripting API is in `premake.api`, code related to command line options in in `premake.options`, and so on.

Organizing the code in this way helps avoid collisions between similarly named functions, and generally helps to keep things tidy.


### Local Variables as Aliases

New namespaces are declared at the top of each source code file, followed by aliases for namespaces which are going to be used frequently within the source file. For example:

```lua
-- define a new namespace for the VC 2010 related code
premake.vstudio.vc2010 = {}

-- create aliases for namespaces we'll use often
local p = premake
local vstudio = p.vstudio
local project = p.project

-- and the "m" alias represents the current module being implemented
local m = p.vstudio.vc2010
```

The alias `p` is used conventionally  as a shortcut for the `premake` namespace. The alias `m` is conventially used to represent the module being implemented.

Using aliases saves some keystrokes when coding. And since Premake embeds all of its scripts into the release executables, it saves on the final download size as well.


### Call Arrays

Premake's project file exporters—which write out the Visual Studio projects, makefiles, and so on—are basically big long lists of "output this, and then this, and then this". This could easily be written (and once was) as one giant function, but then it would be virtually impossible to modify its behavior.

Instead, we split up the generation of a project into many small functions, often writing out only a single line to the output. Any one of these functions can then be overridden by your own scripts or modules.

```lua
-- instead of this...

	function m.outputConfig(cfg)
		if #cfg.defines > 0 or vstudio.isMakefile(cfg) then
			p.x('PreprocessorDefinitions="%s"', table.concat(cfg.defines, ";"))
		end

		if #cfg.undefines > 0 then
			p.x('UndefinePreprocessorDefinitions="%s"', table.concat(cfg.undefines, ";"))
		end

		if cfg.rtti == p.OFF and cfg.clr == p.OFF then
			p.w('RuntimeTypeInfo="false"')
		elseif cfg.rtti == p.ON then
			p.w('RuntimeTypeInfo="true"')
		end
	end

-- we do this...

	function m.preprocessorDefinitions(cfg)
		if #cfg.defines > 0 or vstudio.isMakefile(cfg) then
			p.x('PreprocessorDefinitions="%s"', table.concat(cfg.defines, ";"))
		end
	end

	function m.undefinePreprocessorDefinitions(cfg)
		if #cfg.undefines > 0 then
			p.x('UndefinePreprocessorDefinitions="%s"', table.concat(cfg.undefines, ";"))
		end
	end

	function m.runtimeTypeInfo(cfg)
		if cfg.rtti == p.OFF and cfg.clr == p.OFF then
			p.w('RuntimeTypeInfo="false"')
		elseif cfg.rtti == p.ON then
			p.w('RuntimeTypeInfo="true"')
		end
	end

```

Similarly, instead of implementing the output of a particular section of the project as a function calling a long list of other functions, we put those functions into an array, and then iterate over the array. We call these "call arrays", and they allow you to inject new functions, or remove existing ones, from the array at runtime.

```lua
-- instead of this...

	function m.outputConfig(cfg)
		m.preprocessorDefinitions(cfg)
		m.undefinePreprocessorDefinitions(cfg)
		m.runtimeTypeInfo(cfg)
		-- and so on...
	end

-- we do this

	m.elements.config = function(cfg)
		return {
			m.preprocessorDefinitions,
			m.undefinePreprocessorDefinitions,
			m.runtimeTypeInfo,
			-- and so on...
		}
	end

	function m.outputConfig(cfg)
		p.callArray(m.element.config, cfg)
	end
```

For an example of how to implement a new feature using these conventions, see [Overrides and Call Arrays](Overrides-and-Call-Arrays.md).

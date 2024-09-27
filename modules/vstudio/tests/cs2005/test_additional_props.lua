--
-- tests/actions/vstudio/cs2005/test_additional_props.lua
-- Test the compiler flags of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2023 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_additional_props")
	local dn2005 = p.vstudio.dotnetbase
	local project = p.project


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2005")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.additionalProps(cfg)
	end


--
-- Check handling of AdditionialProps.
-- Elements specified at a time are sorted by name before placement.
--

	function suite.propsAreSorted()
		vsprops {
			Zzz = "zzz",
			Aaa = "aaa",
			Nullable = "enable",
		}
		prepare()
		test.capture [[
		<Aaa>aaa</Aaa>
		<Nullable>enable</Nullable>
		<Zzz>zzz</Zzz>
		]]
	end


--
-- Check handling of nested AdditionalProps.
-- Elements are nested properly.
--

	function suite.propsAreNested()
		vsprops {
			RandomKey = {
				RandomNestedKey = "NestedValue"
			}
		}
		prepare()
		test.capture [[
		<RandomKey>
			<RandomNestedKey>NestedValue</RandomNestedKey>
		</RandomKey>
		]]
	end


--
-- Check handling of AdditionialProps.
-- Element groups set multiple times are placed in the order in which they are set.
--

	function suite.multipleSetPropsAreNotSorted()
		vsprops {
			Zzz = "zzz",
		}
		vsprops {
			Aaa = "aaa",
		}
		vsprops {
			Nullable = "enable",
		}
		prepare()
		test.capture [[
		<Zzz>zzz</Zzz>
		<Aaa>aaa</Aaa>
		<Nullable>enable</Nullable>
		]]
	end


	function suite.xmlEscape()
		vsprops {
			ValueRequiringEscape = "if (age > 3 && age < 8)",
		}
		prepare()
		test.capture [[
		<ValueRequiringEscape>if (age &gt; 3 &amp;&amp; age &lt; 8)</ValueRequiringEscape>
		]]
	end

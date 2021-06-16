local Condition = require('condition')
local Field = require('field')
local set = require('set')

local ConditionMatchTests = test.declare('ConditionMatchTests', 'condition')

local _DEFINES = Field.get('defines')
local _KIND = Field.get('kind')
local _PROJECTS = Field.get('projects')
local _WORKSPACES = Field.get('workspaces')


---
-- A condition with no clauses should always return true
---

function ConditionMatchTests.emptyConditions_matches()
	local cond = Condition.new({})
	test.isTrue(cond:matchesValues(
		{},
		{}
	))
end


---
-- Scoped fields should only match against the provided scope, and not anything in
-- the table of accumulated values.
---

function ConditionMatchTests.scopeField_matches_onMatchingScope()
	local cond = Condition.new({ workspaces = 'Workspace1' })

	test.isTrue(cond:matchesValues(
		{},
		{ [_WORKSPACES] = set.of('Workspace1') }
	))
end


function ConditionMatchTests.scopeField_fails_onNoMatchingScope()
	local cond = Condition.new({ workspaces = 'Workspace1' })

	test.isFalse(cond:matchesValues(
		{},
		{ [_WORKSPACES] = set.of('Workspace2') }
	))
end


function ConditionMatchTests.scopeField_fails_onMatchingValueOnly()
	local cond = Condition.new({ projects = 'Project1' })

	test.isFalse(cond:matchesValues(
		{ [_PROJECTS] = set.of('Project1') },
		{ [_WORKSPACES] = set.of('Workspace1') }
	))
end


---
-- Regular non-scoped fields should match against values, and not the scope.
---

function ConditionMatchTests.valueField_matches_onMatchingValue()
	local cond = Condition.new({ defines = 'X' })

	test.isTrue(cond:matchesValues(
		{ [_DEFINES] = set.of('X') },
		{}
	))
end


function ConditionMatchTests.valueField_matches_onExtraValues()
	local cond = Condition.new({ defines = 'X' })

	test.isTrue(cond:matchesValues(
		{ [_DEFINES] = set.of('X'), [_KIND] = 'StaticLib' },
		{}
	))
end


function ConditionMatchTests.valueField_matches_onMultipleMatches()
	local cond = Condition.new({ defines = 'X', kind = 'StaticLib' })

	test.isTrue(cond:matchesValues(
		{ [_DEFINES] = set.of('X'), [_KIND] = 'StaticLib' },
		{}
	))
end


function ConditionMatchTests.valueField_fails_onNoMatch()
	local cond = Condition.new({ defines = 'X' })

	test.isFalse(cond:matchesValues(
		{ [_DEFINES] = set.of('A') },
		{}
	))
end


function ConditionMatchTests.valueField_fails_onPartialMatch()
	local cond = Condition.new({ defines = 'X', kind = 'StaticLib' })

	test.isFalse(cond:matchesValues(
		{ [_DEFINES] = set.of('A'), [_KIND] = 'StaticLib' },
		{}
	))
end


function ConditionMatchTests.valueField_fails_onScopeOnlyMatch()
	local cond = Condition.new({ defines = 'X' })

	test.isFalse(cond:matchesValues(
		{ [_KIND] = 'StaticLib' },
		{ [_DEFINES] = set.of('X') }
	))
end


function ConditionMatchTests.valueField_fails_onValueNotSet()
	local cond = Condition.new({ defines = 'X' })

	test.isFalse(cond:matchesValues(
		{},
		{}
	))
end

---
-- Conditions represent the "where" tests for a configuration block. If a condition
-- evaluates to `true` then the data contained in the configuration block should be
-- applied.
--
-- Conditions are made up clauses. This condition contains two clauses:
--
--     { system='Windows', kind='SharedLib' }
---

local Field = require('field')
local Type = require('type')

local Condition = Type.declare('Condition')

Condition.NIL_MATCHES_ANY = true
Condition.NIL_MATCHES_NONE = false

local OP_MATCH = 'MATCH'
local OP_AND = 'AND'
local OP_OR = 'OR'
local OP_NOT = 'NOT'

local _allFieldsTested = {}


---
-- Create a new Condition instance.
--
-- @param clauses
--    A table of field-pattern pairs representing the clauses of the condition.
-- @return
--    A new Condition instance representing the specified clauses.
---

function Condition.new(clauses)
	local self = Type.assign(Condition, {
		_fieldsTested = {},
		_rootTest = nil
	})

	local ok, result = pcall(function()
		return Condition._parseCondition(self, clauses)
	end)

	if not ok then
		error(result, 2)
	end

	self._rootTest = result
	return self
end


---
-- Matching function, evaluates a tree of test clauses against a specific collection
-- of values and scopes.
---

local function _match(operation, values, scope, matchOnNil)
	local result

	local op = operation._op

	if op == OP_MATCH then

		local field = operation[1]
		local pattern = operation[2]

		local testValue
		if field.isScope and scope ~= nil then
			testValue = scope[field]
		else
			testValue = values[field]
		end

		if testValue then
			result = Field.matches(field, testValue, pattern, true)
		else
			result = matchOnNil
		end

	elseif op == OP_AND then

		for i = 1, #operation do
			if not _match(operation[i], values, scope, matchOnNil) then
				return false
			end
		end
		return true

	elseif op == OP_NOT then

		return not _match(operation[1], values, scope, matchOnNil)

	elseif op == OP_OR then

		for i = 1, #operation do
			if _match(operation[i], values, scope, matchOnNil) then
				return true
			end
		end
		return false

	end

	return result
end


---
-- Returns a list of all fields that have mentioned in any condition which has been
-- parsed so far.
---

function Condition.allFieldsTested()
	return _allFieldsTested
end


---
-- Checks a list of scopes to see if any is fully tested by this condition.
--
-- Given a scope `{ workspaces='W1', projects='P1' }`, this test will pass and return
-- `true` if the condition has clauses which test `workspaces` and `projects`. It will
-- fail and return false if no clause tests either of those fields.
--
-- This test does not check to see if the scope's values pass the test, only that there
-- *is* a test. Use `Condition.matchesScopeAndValues()` for a full test.
---

function Condition.doesTestScopeValues(self, scopes)
	local fieldsTested = self._fieldsTested

	for i = 1, #scopes do
		local scope = scopes[i]
		local isScopeMatch = true

		for field in pairs(scope) do
			if not fieldsTested[field] then
				isScopeMatch = false
				break
			end
		end

		if isScopeMatch then
			return true
		end
	end

	return false
end


---
-- Compares this condition to a list of scopes, and a collection of values.
--
-- @param values
--    A collection of key-value pairs representing the values to be tested against. Used
--   for fields which do not have the `isScope` flag set.
-- @param scope
--   A list of tables of key-value pairs representing the active query scopes. The list
--   will be iterated, and each scope tested in turn. In order to pass, the condition
--   must contain corresponding clauses which test all keys in the scope, and all clauses
--   in the condition must match the provided values. Fields with the `isScope` flag set
--   will be tested against the scope currently under test.
-- @param matchOnNil
--    If `NIL_MATCHES_ANY` (true), a `nil` value in `scope` or `values` is treated like
--    a wildcard which will match any value. If `NIL_MATCHES_NONE`, `nil` is treat normally,
--    like a missing value which fails testing.
-- @returns
--   If a match is found in the list of scopes, and the values pass the condition, returns
--   the index of the matched scope. If no match is found, returns `nil`.
---

function Condition.matchesScopeAndValues(self, values, scopes, matchOnNil)
	local fieldsTested = self._fieldsTested

	for i = 1, #scopes do
		local scope = scopes[i]

		local isScopeMatch = true
		for field in pairs(scope) do
			if not fieldsTested[field] then
				isScopeMatch = false
				break
			end
		end

		if isScopeMatch and Condition.matchesValues(self, values, scope, matchOnNil) then
			return i
		end
	end

	return nil
end


---
-- Test a condition against a set of values, without enforcing scoping rules.
--
-- Unlike the other matchers, `matchesValues()` only checks to see if its expression is met
-- by the provided values. It does not check to see if the fields required by the scope
-- are actually checked by the condition.
--
-- @param values
--    A collection of key-value pairs representing the values to be tested against. Used
--   for fields which do not have the `isScope` flag set.
-- @param scope
--   A collection of key-value pairs representing the current query scope. Fields with
--   the `isScope` flag set will be tested against this collection, rather than the values.
-- @param matchOnNil
--    If `NIL_MATCHES_ANY` (true), a `nil` value in `scope` or `values` is treated like
--    a wildcard which will match any value. If `NIL_MATCHES_NONE`, `nil` is treat normally,
--    like a missing value which fails testing.
---

function Condition.matchesValues(self, values, scope, matchOnNil)
	local ok, result = pcall(_match, self._rootTest, values, scope, matchOnNil)

	if not ok then
		error(result, 2)
	end

	return result
end


---
-- Merges conditions by AND-ing all of the clauses together.
---

function Condition.merge(left, right)
	local fieldsTested = table.mergeKeys(left._fieldsTested, right._fieldsTested)
	local rootTest = {
		_op = OP_AND,
		left._rootTest, right._rootTest
	}

	return Type.assign(Condition, {
		_fieldsTested = fieldsTested,
		_rootTest = rootTest
	})
end


---
-- Parse incoming user clauses received from the project scripts into a tree
-- of logical operations.
---

function Condition._parseCondition(self, clauses)
	local tests = { _op = OP_AND }

	for key, pattern in pairs(clauses) do
		clause = Condition._parseClause(self, nil, key, pattern)
		table.insert(tests, clause)
	end

	return tests
end


function Condition._parseClause(self, defaultFieldName, fieldName, pattern)
	-- if clause was specified as an array value rather than a key-value pair, parse out the target field name
	if type(fieldName) ~= 'string' then
		-- canonically "not" should be specified after the field name but not everyone thinks that way; move it for them
		local shouldNegate = false
		if string.startsWith(pattern, 'not ') then
			pattern = string.sub(pattern, 5)
			shouldNegate = true
		end
		return Condition._parseFieldName(self, defaultFieldName, pattern, shouldNegate)
	end

	local parts = string.split(pattern, ' or ', true)
	if #parts > 1 then
		return Condition._parseOrOperators(self, fieldName or defaultFieldName, parts)
	end

	if string.startsWith(pattern, 'not ') then
		return Condition._parseNotOperator(self, defaultFieldName, fieldName, pattern)
	end

	-- we've reduced it to a simple 'key=value' test
	local field = Field.get(fieldName)
	self._fieldsTested[field] = true
	_allFieldsTested[field] = true
	return { _op = OP_MATCH, field, pattern }
end


function Condition._parseFieldName(self, defaultFieldName, pattern, shouldNegate)
	local parts = string.split(pattern, ':', true, 1)
	if #parts > 1 then
		fieldName = parts[1]
		pattern = parts[2]
	else
		fieldName = defaultFieldName
	end

	if fieldName == nil then
		error('No field name specified for condition "' .. pattern .. '"', 0)
	end

	if shouldNegate then
		pattern = 'not ' .. pattern
	end

	return Condition._parseClause(self, nil, fieldName, pattern)
end


function Condition._parseNotOperator(self, defaultFieldName, fieldName, pattern)
	pattern = string.sub(pattern, 5)
	return {
		_op = OP_NOT,
		Condition._parseClause(self, defaultFieldName, fieldName, pattern)
	}
end


function Condition._parseOrOperators(self, defaultFieldName, patterns)
	local tests = { _op = OP_OR }

	for i = 1, #patterns do
		local test = Condition._parseClause(self, defaultFieldName, nil, patterns[i])
		table.insert(tests, test)
	end

	return tests
end


return Condition

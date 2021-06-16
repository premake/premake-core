local Condition = require('condition')
local Field = require('field')

local ConditionParsingTests = test.declare('ConditionParsingTests', 'condition')

local _KIND = Field.get('kind')
local _SYSTEM = Field.get('system')


function ConditionParsingTests.singleClause_asKeyValue()
	local cond = Condition.new({ system = 'Windows' })
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'MacOS' }))
end


function ConditionParsingTests.singleClause_asStringValue()
	local cond = Condition.new({ 'system:Windows' })
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'MacOS' }))
end


function ConditionParsingTests.not_asKeyValue()
	local cond = Condition.new({ system = 'not Windows' })
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'MacOS' }))
end


function ConditionParsingTests.not_asStringInline()
	local cond = Condition.new({ 'system:not Windows' })
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'MacOS' }))
end


function ConditionParsingTests.not_asStringPrefix()
	local cond = Condition.new({ 'not system:Windows' })
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'MacOS' }))
end


function ConditionParsingTests.not_asStringInline_withMissingValue()
	local cond = Condition.new({ 'system:not Windows' })
	test.isTrue(cond:matchesValues({}))
end


function ConditionParsingTests.not_asStringPrefix_withMissingValue()
	local cond = Condition.new({ 'not system:Windows' })
	test.isTrue(cond:matchesValues({}))
end


function ConditionParsingTests.or_asKeyValue()
	local cond = Condition.new({ system = 'Windows or MacOS' })
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'MacOS' }))
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'Linux' }))
end


function ConditionParsingTests.or_asStringValue()
	local cond = Condition.new({ 'system:Windows or MacOS' })
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'MacOS' }))
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'Linux' }))
end


function ConditionParsingTests.or_asStringValue_withMixedFields()
	local cond = Condition.new({ 'system:Windows or kind:ConsoleApplication' })
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'Windows' }))
	test.isTrue(cond:matchesValues({ [_KIND] = 'ConsoleApplication' }))
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'Linux' }))
	test.isFalse(cond:matchesValues({ [_KIND] = 'SharedLibrary' }))
end


function ConditionParsingTests.mixedOperators_withLeadingNot()
	local cond = Condition.new({ 'not system:Windows or kind:not ConsoleApplication' })
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'MacOS', [_KIND] = 'SharedLibrary' }))
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'Windows', [_KIND] = 'SharedLibrary' }))
	test.isTrue(cond:matchesValues({ [_SYSTEM] = 'MacOS', [_KIND] = 'ConsoleApplication' }))
	test.isFalse(cond:matchesValues({ [_SYSTEM] = 'Windows', [_KIND] = 'ConsoleApplication' }))
end

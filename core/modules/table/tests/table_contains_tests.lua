local TableContainsTests = test.declare('TableContainsTests', 'table')


function TableContainsTests.contains_isTrue_onValueIsPresent()
	test.isTrue(table.contains({ 'one', 'two', 'three' }, 'two'))
end

function TableContainsTests.contains_isFalse_onValueNotPresent()
	test.isFalse(table.contains({ 'one', 'two', 'three' }, 'four') )
end

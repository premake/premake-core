local StringCapitalizeTests = test.declare('StringCapitalizeTests', 'string')


function StringCapitalizeTests.capitalizesFirstLetter_ifLowerCase()
	test.isEqual('Defines', string.capitalize('defines'))
end


function StringCapitalizeTests.leavesAsIs_ifAlreadyUppercase()
	test.isEqual('Defines', string.capitalize('Defines'))
end

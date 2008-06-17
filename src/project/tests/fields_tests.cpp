/**
 * \file   fields_tests.cpp
 * \brief  Automated tests for the Fields class.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/fields.h"
}

enum TestFields
{
	TestStringValue,
	TestListValue
};

static FieldInfo TestFieldInfo[] =
{
	{ "stringval", StringField },
	{ "listval",   ListField   },
	{  0,          StringField }
};


struct FxFields
{
	Fields fields;

	FxFields()
	{
		fields = fields_create(TestFieldInfo);
	}

	~FxFields()
	{
		fields_destroy(fields);
	}
};


SUITE(fields)
{
	TEST_FIXTURE(FxFields, GetValue_ReturnsNull_OnUnsetString)
	{
		const char* result = fields_get_value(fields, TestStringValue);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxFields, SetValue_CanRoundtrip)
	{
		fields_set_value(fields, TestStringValue, "String Value");
		const char* result = fields_get_value(fields, TestStringValue);
		CHECK_EQUAL("String Value", result);
	}

	TEST_FIXTURE(FxFields, SetValues_CanRoundtrip)
	{
		Strings values = strings_create();
		fields_set_values(fields, TestListValue, values);
		CHECK(values == fields_get_values(fields, TestListValue));
	}
}

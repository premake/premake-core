/**
 * \file   guid_tests.cpp
 * \brief  Automated tests for GUID generation and validation.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/guid.h"
}


SUITE(base)
{
	TEST(GuidCreate_ReturnsCorrectSize)
	{
		const char* guid = guid_create();
		CHECK(guid != NULL && strlen(guid) == 36);
	}

	TEST(GuidCreate_CorrectDashes)
	{
		const char* guid = guid_create();
		CHECK(guid[8]=='-' && guid[13]=='-' && guid[18]=='-' && guid[23]=='-');
	}

	TEST(GuidCreate_CorrectSymbols)
	{
		for (const char* guid = guid_create(); *guid; ++guid)
		{
			const char ch = *guid;
			CHECK((ch>='0' && ch<='9') || (ch>='A' && ch<='F') || (ch=='-'));
		}
	}

	TEST(GuidCreate_CorrectNumOfDashes)
	{
		int num = 0;
		for (const char* guid = guid_create(); *guid; ++guid)
		{
			if (*guid=='-') ++num;
		}
		CHECK(num == 4);
	}

	TEST(GuidIsValid_ReturnsTrue_OnNoBraces)
	{
		CHECK(guid_is_valid("4E67EBCE-BC8B-4058-9AA9-48EE5E003683"));
	}

	TEST(GuidIsValid_ReturnsFalse_OnTooShort)
	{
		CHECK(!guid_is_valid("4E67EBCE-BC8B-4058-9AA9-48EE"));
	}

	TEST(GuidIsValid_ReturnsFalse_OnMissingFirstDash)
	{
		CHECK(!guid_is_valid("4E67EBCE BC8B-4058-9AA9-48EE5E003683"));
	}

	TEST(GuidIsValid_ReturnsFalse_OnMissingSecondDash)
	{
		CHECK(!guid_is_valid("4E67EBCE-BC8B 4058-9AA9-48EE5E003683"));
	}

	TEST(GuidIsValid_ReturnsFalse_OnMissingThirdDash)
	{
		CHECK(!guid_is_valid("4E67EBCE-BC8B-4058 9AA9-48EE5E003683"));
	}

	TEST(GuidIsValid_ReturnsFalse_OnMissingLastDash)
	{
		CHECK(!guid_is_valid("4E67EBCE-BC8B-4058-9AA9 48EE5E003683"));
	}

	TEST(GuidIsValid_ReturnsFalse_OnTooManyDashes)
	{
		CHECK(!guid_is_valid("4E67EBCE-BC8B-4058-9AA9-48EE5-003683"));
	}

	TEST(GuidIsValid_ReturnsFalse_OnInvalidChar)
	{
		CHECK(!guid_is_valid("XE67EBCE-BC8B-4058-9AA9-48EE5X003683"));
	}
}

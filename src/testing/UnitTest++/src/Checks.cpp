#include "Checks.h"
#include <cstring>

namespace UnitTest {

namespace {

	static void WriteEncodedString(UnitTest::MemoryOutStream* stream, const char* value)
{
	if (value == NULL)
	{
		(*stream) << "(null)";
	}
	else
	{
		for (const char* ch = value; *ch; ++ch)
		{
			if (*ch == '\n')
				(*stream) << "\\n";
			else if (*ch == '\t')
				(*stream) << "\\t";
			else if (*ch == '\r')
				(*stream) << "\\r";
			else
				(*stream) << (*ch);
		}
	}
}


void CheckStringsEqual(TestResults& results, char const* expected, char const* actual, 
                       TestDetails const& details)
{
	// JP: Allow NULL values
//  if (std::strcmp(expected, actual))
    if (actual == NULL || std::strcmp(expected, actual))
    {
        UnitTest::MemoryOutStream stream;
//      stream << "Expected " << expected << " but was " << actual;
//		stream << "Expected " << expected << " but was " << (actual ? actual : "(null)");

		stream << "Expected ";
		WriteEncodedString(&stream, expected);
		stream << " but was ";
		WriteEncodedString(&stream, actual);

        results.OnTestFailure(details, stream.GetText());
    }
}

}


void CheckEqual(TestResults& results, char const* expected, char const* actual,
                TestDetails const& details)
{
    CheckStringsEqual(results, expected, actual, details);
}

void CheckEqual(TestResults& results, char* expected, char* actual,
                TestDetails const& details)
{
    CheckStringsEqual(results, expected, actual, details);
}

void CheckEqual(TestResults& results, char* expected, char const* actual,
                TestDetails const& details)
{
    CheckStringsEqual(results, expected, actual, details);
}

void CheckEqual(TestResults& results, char const* expected, char* actual,
                TestDetails const& details)
{
    CheckStringsEqual(results, expected, actual, details);
}


}

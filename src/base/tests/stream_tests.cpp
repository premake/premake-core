/**
 * \file   stream_tests.cpp
 * \brief  Output stream automated tests.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/stream.h"
}

struct FxStream
{
	Stream strm;
	char buffer[1024];

	FxStream()
	{
		strm = stream_create_null();
		stream_set_buffer(strm, buffer);
	}

	~FxStream()
	{
		stream_destroy(strm);
	}
};


SUITE(base)
{
	TEST_FIXTURE(FxStream, Write_WritesValue_OnSimpleValue)
	{
		stream_write(strm, "Hi there!");
		CHECK_EQUAL("Hi there!", buffer);
	}

	TEST_FIXTURE(FxStream, Write_WritesValue_OnFormattedValue)
	{
		stream_write(strm, "Hi there, %s!", "Mr. Bill");
		CHECK_EQUAL("Hi there, Mr. Bill!", buffer);
	}

	TEST_FIXTURE(FxStream, WriteLine_AppendsNewLine_OnSimpleValue)
	{
		stream_writeline(strm, "Hi there!");
		CHECK_EQUAL("Hi there!\n", buffer);
	}

	TEST_FIXTURE(FxStream, WriteLine_AppendsNewLine_OnFormattedValue)
	{
		stream_writeline(strm, "Hi there, %s!", "Mr. Bill");
		CHECK_EQUAL("Hi there, Mr. Bill!\n", buffer);
	}

	TEST_FIXTURE(FxStream, WriteLine_AppendsNewLine_OnModifiedNewline)
	{
		stream_set_newline(strm, "\r\n");
		stream_writeline(strm, "Hi there!");
		CHECK_EQUAL("Hi there!\r\n", buffer);
	}

}

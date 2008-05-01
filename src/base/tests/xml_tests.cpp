/**
 * \file   xml_tests.cpp
 * \brief  XML output tests.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/stream.h"
#include "base/xml.h"
}

struct FxXml
{
	Stream strm;
	Xml xml;
	char buffer[1024];

	FxXml()
	{
		strm = stream_create_null();
		stream_set_buffer(strm, buffer);

		xml = xml_create(strm);
	}

	~FxXml()
	{
		xml_destroy(xml);
		stream_destroy(strm);
	}
};


SUITE(base)
{
	TEST_FIXTURE(FxXml, EndElement_Short)
	{
		xml_element_start(xml, "MyElement");
		xml_element_end(xml, "MyElement");
		CHECK_EQUAL("<MyElement/>\n", buffer);
	}

	TEST_FIXTURE(FxXml, EndElement_Full)
	{
		xml_element_start(xml, "MyElement");
		xml_element_end_full(xml, "MyElement");
		CHECK_EQUAL("<MyElement>\n</MyElement>\n", buffer);
	}

	TEST_FIXTURE(FxXml, ElementNesting_OneDeep)
	{
		xml_element_start(xml, "Element0");
		xml_element_start(xml, "Element1");
		xml_element_end(xml, "Element1");
		xml_element_end(xml, "Element0");
		CHECK_EQUAL(
			"<Element0>\n"
			"\t<Element1/>\n"
			"</Element0>\n",
			buffer);
	}
}
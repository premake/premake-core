/**
 * \file   xml.c
 * \brief  XML output handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "xml.h"


DEFINE_CLASS(Xml)
{
	Stream strm;
	int element_depth;
	int has_children;
};


/**
 * Create a new XML output object around a stream.
 * \param   strm    The stream to which to write XML output.
 * \returns A new XML output object.
 */
Xml xml_create(Stream strm)
{
	Xml xml;
	assert(strm);
	xml = ALLOC_CLASS(Xml);
	xml->strm = strm;
	xml->element_depth = 0;
	xml->has_children = 0;
	return xml;
}


/**
 * Destroy an XML output object and release the associated memory. The stream associated
 * with the object is left intact, and not closed or destroyed.
 * \param   xml    The XML output object to destroy.
 */
void xml_destroy(Xml xml)
{
	assert(xml);
	free(xml);
}


/**
 * Close the current element tag.
 * \param   xml           The XML output object.
 * \param   element_name  The name of the element being ended.
 * \returns OKAY if successful.
 */
int xml_element_end(Xml xml, const char* element_name)
{
	int z = OKAY;

	assert(xml);
	assert(element_name);

	if (xml->has_children)
	{
		z |= stream_writeline(xml->strm, "</%s>", element_name);
	}
	else
	{
		z |= stream_writeline(xml->strm, "/>");
	}

	xml->element_depth--;
	xml->has_children = 1;
	return z;
}


/**
 * Close the current element tag, using the full (</ElementName>) form.
 * \param   xml           The XML output object.
 * \param   element_name  The name of the element being ended.
 * \returns OKAY if successful.
 */
int xml_element_end_full(Xml xml, const char* element_name)
{
	int z;
	assert(xml);
	z  = stream_writeline(xml->strm, ">");
	z |= stream_writeline(xml->strm, "</%s>", element_name);
	return z;
}


/**
 * Start writing a new element tag.
 * \param   xml           The XML output object.
 * \param   element_name  The name of the new element.
 * \returns OKAY if successful.
 */
int xml_element_start(Xml xml, const char* element_name)
{
	int i, z = OKAY;

	assert(xml);
	assert(element_name);

	if (xml->element_depth > 0)
	{
		z |= stream_writeline(xml->strm, ">");
	}

	for (i = 0; i < xml->element_depth; ++i)
	{
		z |= stream_write(xml->strm, "\t");
	}

	xml->element_depth++;
	z |= stream_write(xml->strm, "<%s", element_name);
	return z;
}

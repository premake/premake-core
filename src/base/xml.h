/**
 * \file   xml.h
 * \brief  XML output handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_XML_H)
#define PREMAKE_XML_H

#include "base/stream.h"

DECLARE_CLASS(Xml);

Xml  xml_create(Stream strm);
void xml_destroy(Xml xml);
int  xml_element_end(Xml xml, const char* element_name);
int  xml_element_end_full(Xml xml, const char* element_name);
int  xml_element_start(Xml xml, const char* element_name);

#endif

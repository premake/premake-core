/**
 * \file   fields.h
 * \brief  Project object fields enumeration and handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 *
 * \defgroup fields Object Fields
 * \ingroup  objects
 *
 * The fields class implements a generic collection of string, list, and
 * files fields which are reused by the other project objects.
 *
 * @{
 */
#if !defined(PREMAKE_FIELDS_H)
#define PREMAKE_FIELDS_H

#include "base/strings.h"


/**
 * Field types.
 */
typedef enum enum_FieldKind
{
	StringField,      /**< field containing a single, string value */
	ListField,        /**< field containing a list of string values */
	FilesField,       /**< field containing a list of file names */
	PathField         /**< field containing a file path (directory or file name) */
} FieldKind;


/**
 * Field validation function signature.
 * \param   value   The value to validate.
 * \returns True if the value is considered valid.
 */
typedef int (*FieldValidator)(const char* value);


/**
 * Metadata about a project object field.
 */
typedef struct struct_FieldInfo
{
	const char*    name;        /**< The name of the field. */
	FieldKind kind;             /**< StringField, ListField, etc. */
	FieldValidator validator;   /**< The field validation function */
} FieldInfo;


DECLARE_CLASS(Fields)


Fields      fields_create(FieldInfo* info);
void        fields_destroy(Fields fields);

void        fields_add_value(Fields fields, int index, const char* value);
FieldKind   fields_get_kind(Fields fields, int index);
const char* fields_get_value(Fields fields, int index);
Strings     fields_get_values(Fields fields, int index);
void        fields_set_value(Fields fields, int index, const char* value);
void        fields_set_values(Fields fields, int index, Strings values);
int         fields_size(Fields fields);

#endif
/* @} */

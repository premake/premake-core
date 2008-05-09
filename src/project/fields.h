/**
 * \file   fields.h
 * \brief  Project object fields enumeration and handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_FIELDS_H)
#define PREMAKE_FIELDS_H

#include "base/strings.h"


/**
 * Field types.
 */
enum FieldKind
{
	StringField,
	ListField
};


/**
 * Field validation function signature.
 * \param   value   The value to validate.
 * \returns True if the value is considered valid.
 */
typedef int (*FieldValidator)(const char* value);


/**
 * Metadata about a project object field.
 */
struct FieldInfo
{
	const char*    name;         /**< The name of the field. */
	enum FieldKind kind;         /**< StringField or ListField */
	FieldValidator validator;    /**< The field validation function */
};


DECLARE_CLASS(Fields)


Fields      fields_create(struct FieldInfo* info);
void        fields_destroy(Fields fields);

const char* fields_get_value(Fields fields, int index);
Strings     fields_get_values(Fields fields, int index);
void        fields_set_value(Fields fields, int index, const char* value);
void        fields_set_values(Fields fields, int index, Strings values);

#endif

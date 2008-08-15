/**
 * \file   fields.c
 * \brief  Project object fields enumeration and handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "fields.h"
#include "base/strings.h"


DEFINE_CLASS(Fields)
{
	FieldInfo* info;
	Strings*   values;
	int        count;
};


/**
 * Create a new, empty collection of fields.
 * \param   info   Metadata about the field collection.
 * \returns A new collection of fields.
 */
Fields fields_create(FieldInfo* info)
{
	int i;
	Fields fields;

	assert(info);

	fields = ALLOC_CLASS(Fields);
	fields->info = info;
	
	/* figure out how many fields are in the collection */
	for (i = 0; info[i].name != NULL; ++i);
	fields->count = i;

	/* initialize the values */
	fields->values = (Strings*)malloc(sizeof(Strings) * fields->count);
	for (i = 0; i < fields->count; ++i)
	{
		fields->values[i] = strings_create();
	}

	return fields;
}


/**
 * Destroy a collection of fields and release the associated memory.
 */
void fields_destroy(Fields fields)
{
	int i;

	assert(fields);

	for (i = 0; i < fields->count; ++i)
	{
		strings_destroy(fields->values[i]);
	}
	free(fields->values);
	free(fields);
}


/**
 * Add a new value to the end of an existing list.
 */
void fields_add_value(Fields fields, int index, const char* value)
{
	assert(fields);
	assert(index >= 0 && index < fields->count);
	strings_add(fields->values[index], value);
}


/**
 * Identify the type of field at the given index.
 */
FieldKind fields_get_kind(Fields fields, int index)
{
	assert(fields);
	assert(index >= 0 && index < fields->count);
	return fields->info[index].kind;
}


/**
 * Retrieve the value of a string (single value) field.
 * \returns The field value if set, or NULL.
 */
const char* fields_get_value(Fields fields, int index)
{
	Strings values;
	assert(fields);
	assert(index >= 0 && index < fields->count);

	values = fields->values[index];
	if (strings_size(values) > 0)
	{
		return strings_item(values, 0);
	}
	else
	{
		return NULL;
	}
}


/**
 * Retrieve the list of values for a field.
 */
Strings fields_get_values(Fields fields, int index)
{
	assert(fields);
	assert(index >= 0 && index < fields->count);
	return fields->values[index];
}


/**
 * Sets the value of a string (single value) field.
 */
void fields_set_value(Fields fields, int index, const char* value)
{
	Strings values;

	assert(fields);
	assert(index >= 0 && index < fields->count);

	values = fields->values[index];
	if (strings_size(values) == 0 && value != NULL)
	{
		strings_add(values, value);
	}
	else
	{
		strings_set(values, 0, value);
	}
}


/**
 * Sets the list of values associated with a field. The field will subsequently
 * "own" the list, and take responsibility for destroying it with the field set.
 */
void fields_set_values(Fields fields, int index, Strings values)
{
	assert(fields);
	assert(index >= 0 && index < fields->count);
	assert(values);

	if (fields->values[index] != NULL)
	{
		strings_destroy(fields->values[index]);
	}

	fields->values[index] = values;
}


/**
 * Return the number of fields in the collection.
 */
int fields_size(Fields fields)
{
	assert(fields);
	return fields->count;
}

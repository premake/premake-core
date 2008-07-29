/**
 * \file   filter.c
 * \brief  Configuration filter settings.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "project/filter.h"
#include "base/cstr.h"


DEFINE_CLASS(Filter)
{
	const char* values[NumFilters];
	Script script;
};


/**
 * Create and initialize a new configuration filter.
 * \param   script  A scripting object; used for script_is_match().
 * \returns A new configuration filter.
 */
Filter filter_create(Script script)
{
	int i;

	Filter flt = ALLOC_CLASS(Filter);
	for (i = 0; i < NumFilters; ++i)
	{
		flt->values[i] = NULL;
	}
	flt->script = script;
	return flt;
}


/**
 * Destroy a configuration filter and release the associated memory.
 * \param   flt   The configuration filter to destroy.
 */
void filter_destroy(Filter flt)
{
	assert(flt);
	free(flt);
}


/**
 * Retrieve a filter value.
 * \param   flt       The configuration filter to query.
 * \param   key       The value key to query.
 * \returns The current value of the key.
 */
const char* filter_get_value(Filter flt, enum FilterKey key)
{
	assert(flt);
	assert(key >= 0 && key < NumFilters);
	return flt->values[key];
}


/**
 * Determines if the filter includes the specified list of terms. All terms in the
 * list must be included in the filter.
 * \param   flt      The configuration filter to query.
 * \param   terms    The list of terms to check.
 * \returns True is the list of terms is included in the filter.
 */
int filter_is_match(Filter flt, Strings terms)
{
	int ti, tn;
	
	assert(flt);
	assert(terms);

	tn = strings_size(terms);
	for (ti = 0; ti < tn; ++ti)
	{
		int ki, is_match = 0;

		const char* term = strings_item(terms, ti);
		for (ki = 0; ki < NumFilters; ++ki)
		{
			const char* key = flt->values[ki];
			if (key != NULL && script_is_match(flt->script, key, term))
			{
				is_match = 1;
				break;
			}
		}

		if (!is_match)
		{
			return 0;
		}
	}

	return 1;
}


/**
 * Set a filter value.
 * \param   flt      The configuration filter to set.
 * \param   key      The value key to set.
 * \param   value    The new value for the key.
 */
void filter_set_value(Filter flt, enum FilterKey key, const char* value)
{
	assert(flt);
	assert(key >= 0 && key < NumFilters);
	flt->values[key] = value;
}

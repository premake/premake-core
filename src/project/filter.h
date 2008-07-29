/**
 * \file   filter.h
 * \brief  Configuration filter settings.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \addtogroup project
 * @{
 */
#if !defined(PREMAKE_FILTER_H)
#define PREMAKE_FILTER_H

#include "base/strings.h"
#include "script/script.h"


/**
 * Configuration filter keys.
 */
enum FilterKey
{
	FilterAction,
	FilterConfig,
	FilterOS,
	NumFilters
};


DECLARE_CLASS(Filter)

Filter       filter_create(Script script);
void         filter_destroy(Filter flt);

const char*  filter_get_value(Filter flt, enum FilterKey key);
int          filter_is_match(Filter flt, Strings terms);
void         filter_set_value(Filter flt, enum FilterKey key, const char* value);


#endif
/** @} */

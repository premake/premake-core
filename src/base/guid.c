/**
 * \file   guid.c
 * \brief  GUID creation and validation.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdio.h>
#include <string.h>
#include "premake.h"
#include "guid.h"
#include "platform/platform.h"
#include "base/buffers.h"


static void stringify(char* src, char* dst, int count);


/**
 * Create a new GUID, with the format "4E67EBCE-BC8B-4058-9AA9-48EE5E003683".
 * \returns The new GUID.
 */
const char* guid_create()
{
	char guid[16];
	char* result = buffers_next();

	/* get a GUID as an array of 16 bytes */
	platform_create_guid(guid);

	/* convert that array to a string in the usual format */
	stringify(guid, result, 4);
	result[8] = '-';
	stringify(guid + 4, result + 9, 2);
	result[13] = '-';
	stringify(guid + 6, result + 14, 2);
	result[18] = '-';
	stringify(guid + 8, result + 19, 2);
	result[23] = '-';
	stringify(guid + 10, result + 24, 6);
	result[36] = '\0';
	return result;
}


/**
 * Validate the format of a GUID, which should use the form "4E67EBCE-BC8B-4058-9AA9-48EE5E003683".
 * \param   value    The guid to validate.
 * \returns True if valid, zero otherwise.
 */
int guid_is_valid(const char* value)
{
	int i, n;

	/* make sure it is the right size */
	if (strlen(value) != 36)
		return 0;

	/* check for dashes in the right places */
	if (value[8] != '-' ||
		value[13] != '-' ||
		value[18] != '-' ||
		value[23] != '-')
	{
		return 0;
	}

	/* make sure only [0-9A-F-] are present; count the number of dashes on the way */
	n = 0;
	for (i = 0; i < 36; ++i)
	{
		if (value[i] == '-')
		{
			++n;
		}
		else if ((value[i] < '0' || value[i] > '9') && 
		         (value[i] < 'A' || value[i] > 'F') &&
		         (value[i] < 'a' || value[i] > 'f'))
		{
			return 0;
		}
	}

	/* make sure I've got the right number of dashes */
	if (n != 4)
	{
		return 0;
	}

	return 1;
}


/**
 * Convert an array of bytes to a string.
 * \param src    The source array of bytes.
 * \param dst    The destination string buffer.
 * \param count  The number of bytes to convert.
 */
static void stringify(char* src, char* dst, int count)
{
	int  i;
	for (i = 0; i < count; ++i)
	{
		unsigned value = (unsigned char)src[i];
		sprintf(dst, "%02X", value);
		dst += 2;
	}
}


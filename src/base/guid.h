/**
 * \file   guid.h
 * \brief  GUID creation and validation.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_GUID_H)
#define PREMAKE_GUID_H

const char* guid_create();
int         guid_is_valid(const char* value);

#endif

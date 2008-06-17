/**
 * \file   windows.c
 * \brief  Windows implementation of Premake platform abstraction.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "platform/platform.h"
#if defined(PLATFORM_WINDOWS)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>


DEFINE_CLASS(PlatformSearch)
{
	HANDLE handle;
	int    is_first;
	WIN32_FIND_DATA entry;
};


int platform_create_dir(const char* path)
{
	return CreateDirectory(path, NULL) ? OKAY : !OKAY;
}


void platform_create_guid(char* buffer)
{
	static int (__stdcall *CoCreateGuid)(char*) = NULL;
	if (CoCreateGuid == NULL)
	{
		HMODULE hOleDll = LoadLibrary("OLE32.DLL");
		CoCreateGuid = (int(__stdcall*)(char*))GetProcAddress(hOleDll, "CoCreateGuid");
	}
	CoCreateGuid(buffer);
}


int platform_dir_get_current(char* buffer, int size)
{
	DWORD result = GetCurrentDirectory(size, buffer);
	return (result != 0) ? OKAY : !OKAY;
}


int platform_dir_set_current(const char* path)
{
	DWORD result = SetCurrentDirectory(path);
	return (result != 0) ? OKAY : !OKAY;
}


PlatformSearch platform_search_create(const char* mask)
{
	PlatformSearch search = ALLOC_CLASS(PlatformSearch);
	search->handle = FindFirstFile(mask, &search->entry);
	search->is_first = 1;
	return search;
}


void platform_search_destroy(PlatformSearch search)
{
	if (search->handle != INVALID_HANDLE_VALUE)
	{
		FindClose(search->handle);
	}
	free(search);
}


const char* platform_search_get_name(PlatformSearch search)
{
	return search->entry.cFileName;
}


int platform_search_is_file(PlatformSearch search)
{
	return (search->entry.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0;
}


int platform_search_next(PlatformSearch search)
{
	if (search->handle == INVALID_HANDLE_VALUE)
	{
		return 0;
	}

	if (search->is_first)
	{
		search->is_first = 0;
		return 1;
	}
	else
	{
		return FindNextFile(search->handle, &search->entry);
	}
}

#endif

#include "../premake_internal.h"

#include <stdlib.h>
#include <string.h>
#include "premake.h"


#if PLATFORM_WINDOWS

typedef struct MatchInfo
{
	HANDLE handle;
	WIN32_FIND_DATAW entry;
	int isFirst;
} Matcher;


Matcher* pmk_matchStart(const char* directory, const char* pattern)
{
	char buffer[PATH_MAX];
	strcpy(buffer, directory);
	strcat(buffer, "/");
	strcat(buffer, pattern);

	wchar_t wideMask[PATH_MAX];

	if (MultiByteToWideChar(CP_UTF8, 0, buffer, -1, wideMask, PATH_MAX) == 0) {
		return (NULL);
	}

	Matcher* matcher = (Matcher*)malloc(sizeof(Matcher));
	matcher->handle = FindFirstFileW(wideMask, &matcher->entry);
	matcher->isFirst = TRUE;
	return (matcher);
}


int pmk_matchNext(Matcher* matcher)
{
	if (matcher->handle == INVALID_HANDLE_VALUE) {
		return (FALSE);
	}

	while (TRUE) {
		if (matcher->isFirst) {
			matcher->isFirst = FALSE;
		}
		else if (!FindNextFileW(matcher->handle, &matcher->entry)) {
			return (FALSE);
		}

		if (wcscmp(matcher->entry.cFileName, L".") != 0 && wcscmp(matcher->entry.cFileName, L"..") != 0) {
			return (TRUE);
		}
	}

	return (FALSE);
}


int pmk_matchName(Matcher* matcher, char* buffer, size_t bufferSize)
{
	if (WideCharToMultiByte(CP_UTF8, 0, matcher->entry.cFileName, -1, buffer, bufferSize, NULL, NULL) == 0) {
		return (FALSE);
	}
	return (TRUE);
}


void pmk_matchDone(Matcher* matcher)
{
	if (matcher->handle != INVALID_HANDLE_VALUE)
		FindClose(matcher->handle);
	free(matcher);
}

#else

#include <dirent.h>
#include <fnmatch.h>
#include <sys/stat.h>

typedef struct MatchInfo
{
	DIR* handle;
	struct dirent* entry;
	const char* directory;
	const char* pattern;
} Matcher;


Matcher* pmk_matchStart(const char* directory, const char* pattern)
{
	Matcher* matcher = (Matcher*)malloc(sizeof(Matcher));
	matcher->directory = directory;
	matcher->pattern = pattern;
	matcher->handle = opendir(directory);
	return (matcher);
}


int pmk_matchNext(Matcher* matcher)
{
	if (matcher->handle == NULL)
		return (FALSE);

	matcher->entry = readdir(matcher->handle);
	while (matcher->entry != NULL) {
		const char* name = matcher->entry->d_name;

		if (strcmp(name, ".") != 0 && strcmp(name, "..") != 0) {
			if (fnmatch(matcher->pattern, name, 0) == 0)
				return (TRUE);
		}

		matcher->entry = readdir(matcher->handle);
	}

	return (FALSE);
}


int pmk_matchName(Matcher* matcher, char* buffer, size_t bufferSize)
{
	strncpy(buffer, matcher->entry->d_name, bufferSize);
	return (TRUE);
}


void pmk_matchDone(Matcher* matcher)
{
	if (matcher->handle != NULL)
		closedir(matcher->handle);
	free(matcher);
}

#endif

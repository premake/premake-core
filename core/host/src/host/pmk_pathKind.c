#include "../premake_internal.h"
#include <ctype.h>
#include <string.h>

#if PLATFORM_WINDOWS
#define strncasecmp _strnicmp
#endif


/**
 * Returns the "kind" of a path as one of:
 *
 * - `PMK_PATH_ABSOLUTE`: path is absolute
 * - `PMK_PATH_RELATIVE`: path is relative
 * - `PMK_PATH_KIND_UNKNOWN`: the path kind could not be determine (i.e. it starts with a variable)
 */
int pmk_pathKind(const char* path)
{
	const char* closing;
	size_t length;

	while (path[0] == '"' || path[0] == '!') {
		path++;
	}
	if (path[0] == '/' || path[0] == '\\') {
		return (PMK_PATH_ABSOLUTE);
	}
	if (isalpha(path[0]) && path[1] == ':') {
		return (PMK_PATH_ABSOLUTE);
	}

	// $(foo) and %(foo)
	if ((path[0] == '%' || path[0] == '$') && path[1] == '(') {
		char delimiter = path[0];
		closing = strchr(path + 2, ')');
		if (closing == NULL) {
			return (PMK_PATH_RELATIVE);
		}

		path += 2;

		// special case VS macros %(filename) and %(extension) as normal text
		if (delimiter == '%')
		{
			length = closing - path;
			switch (length) {
			case 8:
				if (strncasecmp(path, "Filename)", length) == 0) {
					return (PMK_PATH_RELATIVE);
				}
				break;
			case 9:
				if (strncasecmp(path, "Extension)", length) == 0) {
					return (PMK_PATH_RELATIVE);
				}
				break;
			default:
				break;
			}
		}

		// only alpha, digits, _ and . allowed inside $()
		while (path < closing) {
			char ch = *path++;
			if (!isalpha(ch) && !isdigit(ch) && ch != '_' && ch != '.') {
				return (PMK_PATH_RELATIVE);
			}
		}

		return (PMK_PATH_ABSOLUTE);
	}

	// $ORIGIN.
	if (path[0] == '$') {
		return (PMK_PATH_ABSOLUTE);
	}

	// either %ORIGIN% or %{<lua code>}
	if (path[0] == '%') {
		if (path[1] == '{') { //${foo} need to defer join until after detokenization
			closing = strchr(path + 2, '}');
			if (closing != NULL) {
				return (PMK_PATH_KIND_UNKNOWN);
			}
		}

		// find the second closing %
		path += 1;
		closing = strchr(path, '%');
		if (closing == NULL) {
			return (PMK_PATH_RELATIVE);
		}

		// need at least one character between the %%
		if (path == closing) {
			return (PMK_PATH_RELATIVE);
		}

		// only alpha, digits and _ allowed inside %..%
		while (path < closing) {
			char ch = *path++;
			if (!isalpha(ch) && !isdigit(ch) && ch != '_') {
				return (PMK_PATH_RELATIVE);
			}
		}

		return (PMK_PATH_ABSOLUTE);
	}

	return (PMK_PATH_RELATIVE);
}

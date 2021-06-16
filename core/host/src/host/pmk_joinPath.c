#include "../premake_internal.h"
#include <string.h>

void pmk_joinPath(char* root, const char* part)
{
	char buffer[PATH_MAX];

	/* if segment is absolute, it becomes the new result */
	if (pmk_isAbsolutePath(part)) {
		strcpy(root, part);
		return;
	}

	strcpy(buffer, part);

	char* segment = strtok(buffer, "/");
	while (segment) {
		if (strcmp(segment, ".") == 0) {
			/* skip over */
		}
		else if (strcmp(segment, "..") == 0) {
			/* if `root` has a trailing slash, pull it off */
			size_t len = strlen(root);
			while (len > 0 && root[len - 1] == '/') --len;
			root[len] = '\0';

			/* identify the root segment to pull off */
			char* separator = strrchr(root, '/');
			char* last = (separator != NULL) ? separator + 1 : root;

			if (strcmp(last, "..") == 0 || strchr(last, '$') || strstr(last, "**")) {
				/* can't trim these; leave intact */
				strcat(root, "/..");
			}
			else if (separator != NULL) {
				/* trim off last segment */
				*separator = '\0';
			}
			else if (len == 0 || strcmp(root, ".") == 0) {
				strcpy(root, "..");
			}
			else {
				strcpy(root, ".");
			}
		}
		else if (strcmp(root, ".") == 0) {
			strcpy(root, segment);
		}
		else {
			size_t len = strlen(root);
			if (len > 0 && root[len - 1] != '/') {
				strcat(root, "/");
			}
			strcat(root, segment);
		}

		segment = strtok(NULL, "/");
	}
}

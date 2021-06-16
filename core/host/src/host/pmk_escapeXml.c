#include "../premake_internal.h"

#include <string.h>


static int appendChar(char* result, int index, char value)
{
	if ((index + 1) < (PATH_MAX - 1)) {
		result[index] = value;
		return (1);
	} else {
		return (0);
	}
}


static int appendStr(char* result, int index, const char* value)
{
	int len = strlen(value);
	if ((index + len) < (PATH_MAX - 1)) {
		strcpy(result + index, value);
		return (len);
	} else {
		return (0);
	}
}


void pmk_escapeXml(char* result, const char* value)
{
	int i = 0;

	while (*value != '\0') {
		switch (*value)
		{
		case '&':
			i += appendStr(result, i, "&amp;");
			break;

		case '<':
			i += appendStr(result, i, "&lt;");
			break;

		case '>':
			i += appendStr(result, i, "&gt;");
			break;

		case '"':
			i += appendStr(result, i, "&quot;");
			break;

		default:
			i += appendChar(result, i, *value);
			break;
		}

		++value;
	}

	result[i] = '\0';
}

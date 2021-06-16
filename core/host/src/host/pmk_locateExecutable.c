#include "../premake_internal.h"
#include <string.h>

#if PLATFORM_MACOS
#include <CoreFoundation/CFBundle.h>
#endif

#if PLATFORM_BSD
#include <sys/types.h>
#include <sys/sysctl.h>
#endif

/**
 * Locate the Premake executable on the file system.
 *
 * Based on:
 * http://sourceforge.net/tracker/index.php?func=detail&aid=3351583&group_id=71616&atid=531880
 * http://stackoverflow.com/questions/933850/how-to-find-the-location-of-the-executable-in-c
 * http://stackoverflow.com/questions/1023306/finding-current-executables-path-without-proc-self-exe
 *
 * @param result
 *    A buffer to hold the resulting path.
 * @param argv9
 *    A value of `argv[0]` as received by `main()`.
 */
void pmk_locateExecutable(char* result, const char* argv0)
{
	const char* path = NULL;

#if PLATFORM_WINDOWS
	wchar_t wideBuffer[PATH_MAX];
	DWORD len = GetModuleFileNameW(NULL, wideBuffer, PATH_MAX);
	if (len > 0 && WideCharToMultiByte(CP_UTF8, 0, wideBuffer, len, result, PATH_MAX, NULL, NULL) != 0) {
		result[len] = '\0';
		path = result;
	}
#endif

#if PLATFORM_MACOS
	CFURLRef bundleURL = CFBundleCopyExecutableURL(CFBundleGetMainBundle());
	CFStringRef pathRef = CFURLCopyFileSystemPath(bundleURL, kCFURLPOSIXPathStyle);
	if (CFStringGetCString(pathRef, result, PATH_MAX - 1, kCFStringEncodingUTF8)) {
		path = result;
	}
#endif

#if PLATFORM_LINUX
	int len = readlink("/proc/self/exe", result, PATH_MAX - 1);
	if (len > 0) {
		result[len] = '\0';
		path = result;
	}
#endif

#if PLATFORM_BSD && !defined(__OpenBSD__)
	int len = readlink("/proc/curproc/file", result, PATH_MAX - 1);

	if (len < 0) {
		len = readlink("/proc/curproc/exe", result, PATH_MAX - 1);
	}

	if (len < 0) {
		int mib[4];
		mib[0] = CTL_KERN;
		mib[1] = KERN_PROC;
		mib[2] = KERN_PROC_PATHNAME;
		mib[3] = -1;
		size_t cb = sizeof(result);
		sysctl(mib, 4, result, &cb, NULL, 0);
		len = (int)cb;
	}

	if (len > 0) {
		result[len] = '\0';
		path = result;
	}
#endif

#if PLATFORM_SOLARIS
	int len = readlink("/proc/self/path/a.out", result, PATH_MAX - 1);
	if (len > 0) {
		result[len] = '\0';
		path = result;
	}
#endif

	/* As a fallback, search the PATH with argv[0] */
	if (!path && getenv("PATH") != NULL) {
		char* segments = getenv("PATH");

#if PLATFORM_WINDOWS
		const char* separator = ";";
#else
		const char* separator = ":";
#endif

		const char* segment = strtok(segments, separator);
		while (segment != NULL) {
			strcpy(result, segment);
			strcat(result, "/");
			strcat(result, argv0);
			segment = strtok(NULL, separator);
			if (pmk_isFile(result)) {
				path = result;
				break;
			}
		}
	}

	/* If all else fails, use argv[0] as-is and hope for the best */
	if (!path) {
		path = argv0;
	}

	/* Make sure we return an absolute path */
	pmk_getAbsolutePath(result, path, NULL);
}

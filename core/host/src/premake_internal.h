#include "premake.h"
#include <stdlib.h>

/* Identify the current platform. I'm not sure how to reliably detect
 * Windows, but since it is the most common I use it as the default */
#if defined(__linux__)
#define PLATFORM_LINUX (1)
#define PLATFORM_STRING "linux"
#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__)
#define PLATFORM_BSD (1)
#define PLATFORM_STRING "bsd"
#elif defined(__APPLE__) && defined(__MACH__)
#define PLATFORM_MACOS (1)
#define PLATFORM_STRING "macosx"
#elif defined(__sun__) && defined(__svr4__)
#define PLATFORM_SOLARIS (1)
#define PLATFORM_STRING "solaris"
#elif defined(__HAIKU__)
#define PLATFORM_HAIKU (1)
#define PLATFORM_STRING "haiku"
#elif defined (_AIX)
#define PLATFORM_AIX (1)
#define PLATFORM_STRING "aix"
#elif defined (__GNU__)
#define PLATFORM_HURD (1)
#define PLATFORM_STRING "hurd"
#else
#define PLATFORM_WINDOWS (1)
#define PLATFORM_STRING "windows"
#endif

#define PLATFORM_POSIX  (PLATFORM_LINUX || PLATFORM_BSD || PLATFORM_MACOS || PLATFORM_SOLARIS)


/* Pull in platform-specific headers required by built-in functions */
#if PLATFORM_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <unistd.h>
#endif
#include <stdint.h>

/* Not all platforms define this */
#ifndef FALSE
#define FALSE (0)
#endif
#ifndef TRUE
#define TRUE (1)
#endif

/* Fill in any missing bits */
#ifndef PATH_MAX
#define PATH_MAX   (4096)
#endif

/* Engine interface */

#define PMK_OPTION_KEY_MAX    (64)
#define PMK_PATH_KIND_UNKNOWN (0)
#define PMK_PATH_ABSOLUTE     (1)
#define PMK_PATH_RELATIVE     (2)

struct pmk_State {
	lua_State* L;
	pmk_ErrorHandler onError;
};


typedef struct MatchInfo Matcher;

typedef int (*LuaLoader)(lua_State* L, const char* filename, const char* mode);

void  pmk_bufferClose(pmk_Buffer* b);
const char* pmk_bufferContents(pmk_Buffer* b);
pmk_Buffer* pmk_bufferInit();
size_t pmk_bufferLen(pmk_Buffer* b);
void pmk_bufferPrintf(pmk_Buffer* b, const char* fmt, ...);
void pmk_bufferPuts(pmk_Buffer* b, const char* ptr, size_t len);
int  pmk_chdir(const char* path);
int  pmk_compareFile(const char* path, const char* contents);
int  pmk_doFile(lua_State* L, const char* filename);
int  pmk_endsWith(const char* haystack, const char* needle);
void pmk_escapeXml(char* result, const char* value);
const char* pmk_getAbsolutePath(char* result, const char* value, const char* relativeTo);
int  pmk_getCwd(char* result);
void pmk_getDirectory(char* result, const char* value);
int  pmk_getFileBaseName(char* result, const char* path);
int  pmk_getFileName(char* result, const char* path);
const char* pmk_getRelativeFile(char* result, const char* baseFile, const char* targetFile);
const char* pmk_getRelativePath(char* result, const char* basePath, const char* targetPath);
int  pmk_getTextColor();
uint32_t pmk_hash(const char* value, int seed);
int  pmk_isAbsolutePath(const char* path);
int  pmk_isFile(const char* filename);
void pmk_joinPath(char* root, const char* segment);
int  pmk_load(lua_State* L, const char* filename);
int  pmk_loadFile(lua_State* L, const char* filename);
int  pmk_loader(lua_State* L, const char* filename, const char* mode, LuaLoader lua_loader);
const char* pmk_locate(char* result, const char* name, const char* paths[], const char* patterns[]);
void pmk_locateExecutable(char* result, const char* argv0);
const char* pmk_locateModule(char* result, lua_State* L, const char* moduleName);
const char* pmk_locateScript(char* result, lua_State* L, const char* filename);
int  pmk_mapStrings(lua_State* L, int valueIndex, const char* param, const char* (*mappingFunction)(char*, const char*, const char*));
void pmk_matchDone(Matcher* matcher);
int  pmk_matchName(Matcher* matcher, char* buffer, size_t bufferSize);
int  pmk_matchNext(Matcher* matcher);
int  pmk_mkdir(const char* path);
Matcher* pmk_matchStart(const char* directory, const char* pattern);
int  pmk_moduleLoader(lua_State* L);
void pmk_normalize(char* result, const char* path);
FILE* pmk_openFile(const char* path, const char* mode);
int  pmk_pathKind(const char* path);
int  pmk_patternFromWildcards(char* result, int maxLen, const char* value, int isPath);
int  pmk_pcall(lua_State* L, int nargs, int nresults);
const char** pmk_searchPaths(lua_State* L);
int  pmk_startsWith(const char* haystack, const char* needle);
int  pmk_testStrings(lua_State* L, int (*testFunction)(const char*, const char*));
int  pmk_touchFile(const char* path);
const char* pmk_translatePath(char* result, const char* value, const char* separator);
void pmk_translatePathInPlace(char* value, const char* separator);
int  pmk_uuid(char* result, const char* value);
int  pmk_writeFile(const char* path, const char* contents);

/* Global extensions */

int g_doFile(lua_State* L);
int g_forceRequire(lua_State* L);
int g_loadFile(lua_State* L);
int g_loadFileOpt(lua_State* L);

/* I/O library extensions */

int pmk_io_compareFile(lua_State* L);
int pmk_io_writeFile(lua_State* L);

/* String buffer library extensions */

int pmk_buffer_new(lua_State* L);
int pmk_buffer_close(lua_State* L);
int pmk_buffer_toString(lua_State* L);
int pmk_buffer_write(lua_State* L);
int pmk_buffer_writeLine(lua_State* L);

/* OS library extensions */

int pmk_os_chdir(lua_State* L);
int pmk_os_getCwd(lua_State* L);
int pmk_os_isFile(lua_State* L);
int pmk_os_matchDone(lua_State* L);
int pmk_os_matchName(lua_State* L);
int pmk_os_matchNext(lua_State* L);
int pmk_os_matchStart(lua_State* L);
int pmk_os_mkdir(lua_State* L);
int pmk_os_touch(lua_State* L);
int pmk_os_uuid(lua_State* L);

/* Path library functions */

int pmk_path_getAbsolute(lua_State* L);
int pmk_path_getBaseName(lua_State* L);
int pmk_path_getDirectory(lua_State* L);
int pmk_path_getName(lua_State* L);
int pmk_path_getKind(lua_State* L);
int pmk_path_getRelative(lua_State* L);
int pmk_path_getRelativeFile(lua_State* L);
int pmk_path_isAbsolute(lua_State* L);
int pmk_path_join(lua_State* L);
int pmk_path_normalize(lua_State* L);
int pmk_path_translate(lua_State* L);

/* Premake library function */

int pmk_premake_locateModule(lua_State* L);
int pmk_premake_locateScript(lua_State* L);

/* String library extensions */

int pmk_string_contains(lua_State* L);
int pmk_string_endsWith(lua_State* L);
int pmk_string_join(lua_State* L);
int pmk_string_hash(lua_State* L);
int pmk_string_patternFromWildcards(lua_State* L);
int pmk_string_startsWith(lua_State* L);

/* Terminal output library functions */

int pmk_terminal_textColor(lua_State* L);

/* XML library functions */

int pmk_xml_escape(lua_State* L);

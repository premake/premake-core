#define lua_c
#include "lua/src/lua.h"
#include "lua/src/lauxlib.h"
#include "lua/src/lualib.h"

/* A Premake context object */
typedef struct pmk_State pmk_State;

/* String buffer type */
typedef struct pmk_Buffer pmk_Buffer;

/* A success return code */
#define OKAY   (0)

/* Terminal output color constants */
#define PMK_COLOR_BLACK (0)
#define PMK_COLOR_BLUE (1)
#define PMK_COLOR_GREEN (2)
#define PMK_COLOR_CYAN (3)
#define PMK_COLOR_RED (4)
#define PMK_COLOR_PURPLE (5)
#define PMK_COLOR_BROWN (6)
#define PMK_COLOR_LIGHTGRAY (7)
#define PMK_COLOR_GRAY (8)
#define PMK_COLOR_LIGHTBLUE  (9)
#define PMK_COLOR_LIGHTGREEN (10)
#define PMK_COLOR_LIGHTCYAN (11)
#define PMK_COLOR_LIGHTRED (12)
#define PMK_COLOR_MAGENTA (13)
#define PMK_COLOR_YELLOW (14)
#define PMK_COLOR_WHITE (15)

#define PMK_COLOR_WARNING PMK_COLOR_MAGENTA
#define PMK_COLOR_ERROR PMK_COLOR_RED
#define PMK_COLOR_INFO PMK_COLOR_LIGHTCYAN


/**
 * Error handling function; provide your own to `pmk_init`.
 */
typedef void (*pmk_ErrorHandler)(const char* message, const char* traceback);

/**
 * Initialize the Premake engine and embedded Lua runtime.
 */
pmk_State* pmk_init(pmk_ErrorHandler onError);

/**
 * Shut down the Premake engine and Lua runtime and clean everything up.
 */
void pmk_close(pmk_State* P);

/**
 * Evaluate a set of command line options and do what they say. See
 * the Premake usage documentation online for a full description of
 * the command line options.
 */
int pmk_execute(pmk_State* P, int argc, const char** argv);

/**
 * Returns a reference to Premake's embedded Lua runtime state.
 */
lua_State* pmk_luaState(pmk_State* P);

/**
 * Set the terminal output color.
 */
void pmk_setTextColor(int color);

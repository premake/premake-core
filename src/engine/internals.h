/**
 * \file   internals.h
 * \brief  Engine internal API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_INTERNALS_H)
#define PREMAKE_INTERNALS_H

#include "engine/session.h"

#define lua_c
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"


/* string constants for script variables and functions */
#define ACTION_KEY         "_ACTION"
#define CONFIGURATION_KEY  "configuration"
#define FILE_KEY           "_FILE"
#define PROJECT_KEY        "project"
#define PROJECTS_KEY       "projects"
#define SESSION_KEY        "_SESSION"
#define SOLUTION_KEY       "solution"
#define SOLUTIONS_KEY      "_SOLUTIONS"


/** Used to specify type of object for engine_get/set_active_object */
enum ObjectType
{
	SolutionObject = 0x01,
	ProjectObject  = 0x02,
	ConfigObject   = 0x04
};

#define OPTIONAL     (0)
#define REQUIRED     (1)


/* Internal engine API - script helpers */
int         engine_get_active_object(lua_State* L, enum ObjectType type, int is_required);
void        engine_set_active_object(lua_State* L, enum ObjectType type);
void        engine_set_script_file(lua_State* L, const char* filename);
const char* engine_get_script_dir(lua_State* L);
void        engine_configure_project_object(lua_State* L, struct FieldInfo* fields);

/* Internal session API */
lua_State*  session_get_lua_state(Session sess);


/* Generic project object field getter/setter API */
int accessor_register_all(lua_State* L);


/* Project object unloading API. The unload functions "interface" provides an
 * opportunity to mock the actual implementation for automated testing */
struct UnloadFuncs
{
	int (*unload_solution)(Session sess, lua_State* L, Solution sln);
	int (*unload_project)(Session sess, lua_State* L, Project prj);
};

int  unload_all(Session sess, lua_State* L, struct UnloadFuncs* funcs);
int  unload_solution(Session sess, lua_State* L, Solution sln);
int  unload_project(Session sess, lua_State* L, Project prj);


/* Script function handlers */
int  fn_dofile(lua_State* L);
int  fn_error(lua_State* L);
int  fn_getcwd(lua_State* L);
int  fn_include(lua_State* L);
int  fn_project(lua_State* L);
int  fn_solution(lua_State* L);

#endif


/**
 * \file   script_internal.h
 * \brief  Project scripting engine internal API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_SCRIPT_INTERNAL_H)
#define PREMAKE_SCRIPT_INTERNAL_H

#include "script.h"
#include "session/session.h"

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

lua_State*  script_get_lua(Script script);

/* internal state management */
int         script_internal_get_active_object(lua_State* L, enum ObjectType type, int is_required);
void        script_internal_set_active_object(lua_State* L, enum ObjectType type);
const char* script_internal_script_dir(lua_State* L);
void        script_internal_populate_object(lua_State* L, struct FieldInfo* fields);

/* Generic project object field getter/setter API */
int  fn_accessor_register_all(lua_State* L);

/* script function handlers */
int  fn_dofile(lua_State* L);
int  fn_error(lua_State* L);
int  fn_getcwd(lua_State* L);
int  fn_include(lua_State* L);
int  fn_match(lua_State* L);
int  fn_project(lua_State* L);
int  fn_solution(lua_State* L);

/* Project object unloading API. The unload functions "interface" provides an
 * opportunity to mock the actual implementation for automated testing */
struct UnloadFuncs
{
	int (*unload_solution)(lua_State* L, Solution sln);
	int (*unload_project)(lua_State* L, Project prj);
};

int  unload_all(lua_State* L, Array slns, struct UnloadFuncs* funcs);
int  unload_solution(lua_State* L, Solution sln);
int  unload_project(lua_State* L, Project prj);


#endif

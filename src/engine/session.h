/**
 * \file   session.h
 * \brief  Context for a program execution session.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_SESSION_H)
#define PREMAKE_SESSION_H

#include "base/stream.h"
#include "project/solution.h"
#include "project/project.h"

DECLARE_CLASS(Session)


/**
 * Callback signature for Premake action handlers, which will get triggered
 * if user specifies that action on the command line for processing.
 * \param   sess   The current execution session context.
 * \returns OKAY   If successful.
 */
typedef int (*SessionActionCallback)(Session sess);


/** 
 * Per-solution object callback signature for session_enumerate_objects(). The
 * solution callback will be called once for each solution in the session.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream(). May be NULL.
 * \returns OKAY if successful.
 */
typedef int (*SessionSolutionCallback)(Session sess, Solution sln, Stream strm);


/** 
 * Per-project object callback signature for session_enumerate_objects(). The
 * project callback will be called once for each solution in the session.
 * \param   sess    The execution session context.
 * \param   prj     The current project.
 * \param   strm    The currently active stream; set with session_set_active_stream(). May be NULL.
 * \returns OKAY if successful.
 */
typedef int (*SessionProjectCallback)(Session sess, Project prj, Stream strm);


/**
 * Describe a Premake action, including the handler function and the metadata
 * required to list it in the user help.
 */
typedef struct struct_SessionAction
{
	const char* name;
	const char* description;
	SessionActionCallback callback;
} SessionAction;


Session     session_create(void);
void        session_destroy(Session sess);
void        session_add_solution(Session sess, Solution sln);
int         session_enumerate_configurations(Session sess, Project prj, Stream strm);
int         session_enumerate_objects(Session sess, SessionSolutionCallback* sln_funcs, SessionProjectCallback* prj_funcs, SessionProjectCallback* cfg_funcs);
const char* session_get_action(Session sess);
Stream      session_get_active_stream(Session sess);
Solution    session_get_solution(Session sess, int index);
int         session_num_solutions(Session sess);
const char* session_run_file(Session sess, const char* filename);
const char* session_run_string(Session sess, const char* script);
void        session_set_action(Session sess, const char* action);
void        session_set_active_stream(Session sess, Stream strm);
int         session_unload(Session sess);
int         session_validate(Session sess);

#endif

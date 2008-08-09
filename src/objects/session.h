/**
 * \file   session.h
 * \brief  Context for a program execution session.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 *
 * \defgroup session Session
 * \ingroup  objects
 *
 * The session is the top-level object, providing containment and enumeration
 * of a set of solutions (and their contained projects, etc.)
 *
 * @{
 */
#if !defined(PREMAKE_SESSION_H)
#define PREMAKE_SESSION_H

DECLARE_CLASS(Session)

#include "base/stream.h"
#include "objects/solution.h"
#include "objects/project.h"



/** 
 * Per-solution object callback signature for session_enumerate_objects(). The
 * solution callback will be called once for each solution in the session.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream(). May be NULL.
 * \returns OKAY if successful.
 */
typedef int (*SessionSolutionCallback)(Solution sln, Stream strm);


/** 
 * Per-project object callback signature for session_enumerate_objects(). The
 * project callback will be called once for each solution in the session.
 * \param   sess    The execution session context.
 * \param   prj     The current project.
 * \param   strm    The currently active stream; set with session_set_active_stream(). May be NULL.
 * \returns OKAY if successful.
 */
typedef int (*SessionProjectCallback)(Project prj, Stream strm);


/**
 * Describe the features (languages, project kinds, etc.) supported by an action. Used by
 * session_validate() to ensure that action handler functions only get called with data
 * that they can handle.
 */
typedef struct struct_SessionFeatures
{
	const char* languages[64];
} SessionFeatures;


Session     session_create(void);
void        session_destroy(Session sess);
void        session_add_solution(Session sess, Solution sln);
int         session_enumerate_configurations(Project prj, Stream strm);
int         session_enumerate_objects(Session sess, SessionSolutionCallback* sln_funcs, SessionProjectCallback* prj_funcs, SessionProjectCallback* cfg_funcs);
Stream      session_get_active_stream(Session sess);
Solution    session_get_solution(Session sess, int index);
int         session_num_solutions(Session sess);
void        session_set_active_stream(Session sess, Stream strm);
int         session_tests(void);
int         session_validate(Session sess, SessionFeatures* features);

#endif
/** @} */


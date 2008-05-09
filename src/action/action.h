/**
 * \file   action.h
 * \brief  Built-in engine actions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_ACTION_H)
#define PREMAKE_ACTION_H

#include "session/session.h"


/**
 * State values for the source tree enumeration functions.
 */
enum ActionSourceState
{
	GroupStart,
	GroupEnd,
	SourceFile
};


/**
 * Per-file callback signature for action_source_tree.
 * \param   sess      The current execution state context.
 * \param   prj       The current project; contains the file being enumerated.
 * \param   strm      The active output stream; for writing the file markup.
 * \param   filename  The name of the file to process.
 * \param   state     One of the ActionSourceStates, enabling file grouping.
 * \returns OKAY if successful.
 */
typedef int (*ActionSourceCallback)(Session sess, Project prj, Stream strm, const char* filename, int state);


/* the list of built-in Premake actions */
extern SessionAction Actions[];

int  gmake_action(Session sess);
int  vs2002_action(Session sess);
int  vs2003_action(Session sess);
int  vs2005_action(Session sess);
int  vs2008_action(Session sess);


/* support functions */
int  action_source_tree(Session sess, Project prj, Stream strm, ActionSourceCallback handler);


#endif

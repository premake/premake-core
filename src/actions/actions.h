/**
 * \file   actions.h
 * \brief  Built-in engine actions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \defgroup action Actions
 *
 * The actions component contains the implementation of all of the built-in
 * Premake actions, along with a few common support functions.
 *
 * @{
 */
#if !defined(PREMAKE_ACTIONS_H)
#define PREMAKE_ACTIONS_H

#include "session/session.h"


int  gmake_action (Session sess);
int  vs2002_action(Session sess);
int  vs2003_action(Session sess);
int  vs2005_action(Session sess);
int  vs2008_action(Session sess);


/* the list of built-in Premake actions */
extern SessionAction Actions[];


#endif
/** @} */

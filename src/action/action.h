/**
 * \file   action.h
 * \brief  Built-in engine actions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_ACTION_H)
#define PREMAKE_ACTION_H

#include "session/session.h"

extern SessionAction Actions[];

int  gmake_action(Session sess);
int  vs2002_action(Session sess);
int  vs2003_action(Session sess);
int  vs2005_action(Session sess);
int  vs2008_action(Session sess);

#endif

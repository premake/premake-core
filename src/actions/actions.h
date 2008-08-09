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

#include "objects/session.h"


/**
 * Callback signature for Premake action handlers, which will get triggered
 * if user specifies that action on the command line for processing.
 * \param   sess   The current execution session context.
 * \returns OKAY   If successful.
 */
typedef int (*ActionCallback)(Session sess);


/**
 * Describe a Premake action, including the handler function and the metadata
 * required to list it in the user help.
 */
typedef struct struct_ActionInfo
{
	const char* name;
	const char* description;
	ActionCallback callback;
} ActionInfo;


/* the list of built-in Premake actions */
extern ActionInfo Actions[];



#endif
/** @} */

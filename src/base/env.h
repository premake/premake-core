/**
 * \file   env.h
 * \brief  Manage the runtime environment state.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \defgroup env Runtime Environment
 * \ingroup  base
 *
 * Manage the runtime environment state, getting and setting such values as
 * the target action and the operating system.
 *
 * @{
 */
#if !defined(PREMAKE_ENV_H)
#define PREMAKE_ENV_H

/**
 * The currently supported operating systems.
 * \note If you add to this list, be sure to also update the detection
 *       and string translation logic.
 */
enum OS
{
	UnknownOS,
	BSD,
	Linux,
	MacOSX,
	Windows
};


const char* env_get_action(void);
enum OS     env_get_os(void);
const char* env_get_os_name(void);
int         env_is_os(enum OS id);
void        env_set_action(const char* action);
void        env_set_os(enum OS id);


#endif
/** @} */

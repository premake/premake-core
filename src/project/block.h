/**
 * \file   block.h
 * \brief  Configuration blocks API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \addtogroup project
 * @{
 */
#if !defined(PREMAKE_BLOCK_H)
#define PREMAKE_BLOCK_H

#include "fields.h"


/**
 * Configuration block field index.
 * \note If you modify this list, you must also update BlockFieldInfo[].
 */
enum BlockField
{
	BlockDefines,
	BlockObjDir,
	NumBlockFields
};

extern struct FieldInfo BlockFieldInfo[];


DECLARE_CLASS(Block)

Block      block_create(void);
void       block_destroy(Block blk);

Strings    block_get_defines(Block blk);
Fields     block_get_fields(Block blk);


#endif
/** @} */

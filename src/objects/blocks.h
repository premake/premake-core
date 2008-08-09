/**
 * \file   blocks.h
 * \brief  A list of configuration blocks.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \addtogroup block
 * @{
 */
#if !defined(PREMAKE_BLOCKS_H)
#define PREMAKE_BLOCKS_H

#include "block.h"

DECLARE_CLASS(Blocks)

Blocks     blocks_create(void);
void       blocks_destroy(Blocks blks);

void       blocks_add(Blocks blks, Block blk);
Block      blocks_item(Blocks blks, int index);
int        blocks_size(Blocks blks);


#endif
/** @} */

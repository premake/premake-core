/**
 * \file   premake.h
 * \brief  Global program definitions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */


/**
 * The default filename for Premake scripts.
 */
#define DEFAULT_SCRIPT_NAME   "premake4.lua"


/**
 * The success return code; the symbol avoids confusion about zero == false.
 */
#define OKAY    (0)


/**
 * Macro to declare new "classes" - just opaque struct pointers. The macro
 * ensures that they all get defined consistently.
 */
#define DECLARE_CLASS(n)   typedef struct n##_impl* n;


/**
 * Macro to define new "classes" - just structs with a special name.
 */
#define DEFINE_CLASS(n)    struct n##_impl


/**
 * Macro to allocate memory for a "class" - just a struct with a special name.
 */
#define ALLOC_CLASS(n)     (n)malloc(sizeof(struct n##_impl))


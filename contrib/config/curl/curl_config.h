#ifndef HEADER_CURL_CONFIG_H
#define HEADER_CURL_CONFIG_H

#ifdef _WIN32_WCE
#  include "config-win32ce.h"
#else
#  ifdef WIN32
#    include "config-win32.h"
#  endif
#endif

#if defined(macintosh) && defined(__MRC__)
#  include "config-mac.h"
#endif

#ifdef __riscos__
#  include "config-riscos.h"
#endif

#ifdef __AMIGA__
#  include "config-amigaos.h"
#endif

#ifdef __SYMBIAN32__
#  include "config-symbian.h"
#endif

#ifdef __OS400__
#  include "config-os400.h"
#endif

#ifdef TPF
#  include "config-tpf.h"
#endif

#ifdef __VXWORKS__
#  include "config-vxworks.h"
#endif

#ifdef __linux__
#  include "config-linux.h"
#endif

#ifdef __APPLE__ && __MACH__
#  include "config-osx.h"
#endif

#endif

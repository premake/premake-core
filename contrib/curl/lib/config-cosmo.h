/* lib/curl_config.h.in.  Generated somehow by cmake.  */

/***************************************************************************
 *                                  _   _ ____  _
 *  Project                     ___| | | |  _ \| |
 *                             / __| | | | |_) | |
 *                            | (__| |_| |  _ <| |___
 *                             \___|\___/|_| \_\_____|
 *
 * Copyright (C) Daniel Stenberg, <daniel@haxx.se>, et al.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at https://curl.se/docs/copyright.html.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the COPYING file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 * SPDX-License-Identifier: curl
 *
 ***************************************************************************/

/* Location of default ca bundle */
/* #undef CURL_CA_BUNDLE */

/* define "1" to use built-in ca store of TLS backend */
/* #undef CURL_CA_FALLBACK */

/* Location of default ca path */
/* #undef CURL_CA_PATH */

/* Default SSL backend */
/* #undef CURL_DEFAULT_SSL_BACKEND */

/* disables alt-svc */
/* #undef CURL_DISABLE_ALTSVC */

/* disables cookies support */
/* #undef CURL_DISABLE_COOKIES */

/* disables Basic authentication */
/* #undef CURL_DISABLE_BASIC_AUTH */

/* disables Bearer authentication */
/* #undef CURL_DISABLE_BEARER_AUTH */

/* disables Digest authentication */
/* #undef CURL_DISABLE_DIGEST_AUTH */

/* disables Kerberos authentication */
/* #undef CURL_DISABLE_KERBEROS_AUTH */

/* disables negotiate authentication */
/* #undef CURL_DISABLE_NEGOTIATE_AUTH */

/* disables AWS-SIG4 */
/* #undef CURL_DISABLE_AWS */

/* disables DICT */
/* #undef CURL_DISABLE_DICT */

/* disables DNS-over-HTTPS */
/* #undef CURL_DISABLE_DOH */

/* disables FILE */
/* #undef CURL_DISABLE_FILE */

/* disables form api */
/* #undef CURL_DISABLE_FORM_API */

/* disables FTP */
/* #undef CURL_DISABLE_FTP */

/* disables curl_easy_options API for existing options to curl_easy_setopt */
/* #undef CURL_DISABLE_GETOPTIONS */

/* disables GOPHER */
/* #undef CURL_DISABLE_GOPHER */

/* disables headers-api support */
/* #undef CURL_DISABLE_HEADERS_API */

/* disables HSTS support */
/* #undef CURL_DISABLE_HSTS */

/* disables HTTP */
/* #undef CURL_DISABLE_HTTP */

/* disabled all HTTP authentication methods */
/* #undef CURL_DISABLE_HTTP_AUTH */

/* disables IMAP */
/* #undef CURL_DISABLE_IMAP */

/* disables LDAP */
#define CURL_DISABLE_LDAP 1

/* disables LDAPS */
#define CURL_DISABLE_LDAPS 1

/* disables --libcurl option from the curl tool */
/* #undef CURL_DISABLE_LIBCURL_OPTION */

/* disables MIME support */
/* #undef CURL_DISABLE_MIME */

/* disables local binding support */
/* #undef CURL_DISABLE_BINDLOCAL */

/* disables MQTT */
/* #undef CURL_DISABLE_MQTT */

/* disables netrc parser */
/* #undef CURL_DISABLE_NETRC */

/* disables NTLM support */
/* #undef CURL_DISABLE_NTLM */

/* disables date parsing */
/* #undef CURL_DISABLE_PARSEDATE */

/* disables POP3 */
/* #undef CURL_DISABLE_POP3 */

/* disables built-in progress meter */
/* #undef CURL_DISABLE_PROGRESS_METER */

/* disables proxies */
/* #undef CURL_DISABLE_PROXY */

/* disables IPFS from the curl tool */
/* #undef CURL_DISABLE_IPFS */

/* disables RTSP */
/* #undef CURL_DISABLE_RTSP */

/* disables SHA-512/256 hash algorithm */
/* #undef CURL_DISABLE_SHA512_256 */

/* disabled shuffle DNS feature */
/* #undef CURL_DISABLE_SHUFFLE_DNS */

/* disables SMB */
/* #undef CURL_DISABLE_SMB */

/* disables SMTP */
/* #undef CURL_DISABLE_SMTP */

/* disabled WebSockets */
/* #undef CURL_DISABLE_WEBSOCKETS */

/* disables use of socketpair for curl_multi_poll */
/* #undef CURL_DISABLE_SOCKETPAIR */

/* disables TELNET */
/* #undef CURL_DISABLE_TELNET */

/* disables TFTP */
/* #undef CURL_DISABLE_TFTP */

/* disables verbose strings */
/* #undef CURL_DISABLE_VERBOSE_STRINGS */

/* disables unsafe CA bundle search on Windows from the curl tool */
/* #undef CURL_DISABLE_CA_SEARCH */

/* safe CA bundle search (within the curl tool directory) on Windows */
/* #undef CURL_CA_SEARCH_SAFE */

/* to make a symbol visible */
#define CURL_EXTERN_SYMBOL __attribute__ ((__visibility__ ("default")))
/* Ensure using CURL_EXTERN_SYMBOL is possible */
#ifndef CURL_EXTERN_SYMBOL
#define CURL_EXTERN_SYMBOL
#endif

/* Allow SMB to work on Windows */
/* #undef USE_WIN32_CRYPTO */

/* Use Windows LDAP implementation */
/* #undef USE_WIN32_LDAP */

/* Define if you want to enable IPv6 support */
#define USE_IPV6 1

/* Define to 1 if you have the alarm function. */
#define HAVE_ALARM 1

/* Define to 1 if you have the arc4random function. */
/* #undef HAVE_ARC4RANDOM */

/* Define to 1 if you have the <arpa/inet.h> header file. */
#define HAVE_ARPA_INET_H 1

/* Define to 1 if you have _Atomic support. */
#define HAVE_ATOMIC 1

/* Define to 1 if you have the `fnmatch' function. */
#define HAVE_FNMATCH 1

/* Define to 1 if you have the `basename' function. */
#define HAVE_BASENAME 1

/* Define to 1 if bool is an available type. */
#define HAVE_BOOL_T 1

/* Define to 1 if you have the __builtin_available function. */
/* #undef HAVE_BUILTIN_AVAILABLE */

/* Define to 1 if you have the clock_gettime function and monotonic timer. */
#define HAVE_CLOCK_GETTIME_MONOTONIC 1

/* Define to 1 if you have the clock_gettime function and raw monotonic timer.
   */
#define HAVE_CLOCK_GETTIME_MONOTONIC_RAW 1

/* Define to 1 if you have the `closesocket' function. */
/* #undef HAVE_CLOSESOCKET */

/* Define to 1 if you have the <dirent.h> header file. */
#define HAVE_DIRENT_H 1

/* Define to 1 if you have the `opendir' function. */
#define HAVE_OPENDIR 1

/* Define to 1 if you have the fcntl function. */
#define HAVE_FCNTL 1

/* Define to 1 if you have the <fcntl.h> header file. */
#define HAVE_FCNTL_H 1

/* Define to 1 if you have a working fcntl O_NONBLOCK function. */
#define HAVE_FCNTL_O_NONBLOCK 1

/* Define to 1 if you have the freeaddrinfo function. */
#define HAVE_FREEADDRINFO 1

/* Define to 1 if you have the fseeko function. */
#define HAVE_FSEEKO 1

/* Define to 1 if you have the fseeko declaration. */
#define HAVE_DECL_FSEEKO 1

/* Define to 1 if you have the _fseeki64 function. */
/* #undef HAVE__FSEEKI64 */

/* Define to 1 if you have the ftruncate function. */
#define HAVE_FTRUNCATE 1

/* Define to 1 if you have a working getaddrinfo function. */
#define HAVE_GETADDRINFO 1

/* Define to 1 if the getaddrinfo function is threadsafe. */
#define HAVE_GETADDRINFO_THREADSAFE 1

/* Define to 1 if you have the `geteuid' function. */
#define HAVE_GETEUID 1

/* Define to 1 if you have the `getppid' function. */
#define HAVE_GETPPID 1

/* Define to 1 if you have the gethostbyname_r function. */
#define HAVE_GETHOSTBYNAME_R 1

/* gethostbyname_r() takes 3 args */
/* #undef HAVE_GETHOSTBYNAME_R_3 */

/* gethostbyname_r() takes 5 args */
/* #undef HAVE_GETHOSTBYNAME_R_5 */

/* gethostbyname_r() takes 6 args */
#define HAVE_GETHOSTBYNAME_R_6 1

/* Define to 1 if you have the gethostname function. */
#define HAVE_GETHOSTNAME 1

/* Define to 1 if you have a working getifaddrs function. */
#define HAVE_GETIFADDRS 1

/* Define to 1 if you have the `getpass_r' function. */
/* #undef HAVE_GETPASS_R */

/* Define to 1 if you have the `getpeername' function. */
#define HAVE_GETPEERNAME 1

/* Define to 1 if you have the `getsockname' function. */
#define HAVE_GETSOCKNAME 1

/* Define to 1 if you have the `if_nametoindex' function. */
/* #undef HAVE_IF_NAMETOINDEX */

/* Define to 1 if you have the `getpwuid' function. */
#define HAVE_GETPWUID 1

/* Define to 1 if you have the `getpwuid_r' function. */
#define HAVE_GETPWUID_R 1

/* Define to 1 if you have the `getrlimit' function. */
#define HAVE_GETRLIMIT 1

/* Define to 1 if you have the `gettimeofday' function. */
#define HAVE_GETTIMEOFDAY 1

/* Define to 1 if you have a working glibc-style strerror_r function. */
#define HAVE_GLIBC_STRERROR_R 1

/* Define to 1 if you have a working gmtime_r function. */
#define HAVE_GMTIME_R 1

/* if you have the gssapi libraries */
/* #undef HAVE_GSSAPI */

/* Define to 1 if you have the <gssapi/gssapi_generic.h> header file. */
/* #undef HAVE_GSSAPI_GSSAPI_GENERIC_H */

/* Define to 1 if you have the <gssapi/gssapi.h> header file. */
/* #undef HAVE_GSSAPI_GSSAPI_H */

/* Define to 1 if you have the <gssapi/gssapi_krb5.h> header file. */
/* #undef HAVE_GSSAPI_GSSAPI_KRB5_H */

/* if you have the GNU gssapi libraries */
/* #undef HAVE_GSSGNU */

/* Define to 1 if you have the <ifaddrs.h> header file. */
#define HAVE_IFADDRS_H 1

/* Define to 1 if you have a IPv6 capable working inet_ntop function. */
#define HAVE_INET_NTOP 1

/* Define to 1 if you have a IPv6 capable working inet_pton function. */
#define HAVE_INET_PTON 1

/* Define to 1 if symbol `sa_family_t' exists */
#define HAVE_SA_FAMILY_T 1

/* Define to 1 if symbol `ADDRESS_FAMILY' exists */
/* #undef HAVE_ADDRESS_FAMILY */

/* Define to 1 if you have the ioctlsocket function. */
/* #undef HAVE_IOCTLSOCKET */

/* Define to 1 if you have the IoctlSocket camel case function. */
/* #undef HAVE_IOCTLSOCKET_CAMEL */

/* Define to 1 if you have a working IoctlSocket camel case FIONBIO function.
   */
/* #undef HAVE_IOCTLSOCKET_CAMEL_FIONBIO */

/* Define to 1 if you have a working ioctlsocket FIONBIO function. */
/* #undef HAVE_IOCTLSOCKET_FIONBIO */

/* Define to 1 if you have a working ioctl FIONBIO function. */
#define HAVE_IOCTL_FIONBIO 1

/* Define to 1 if you have a working ioctl SIOCGIFADDR function. */
#define HAVE_IOCTL_SIOCGIFADDR 1

/* Define to 1 if you have the <io.h> header file. */
/* #undef HAVE_IO_H */

/* Define to 1 if you have the lber.h header file. */
/* #undef HAVE_LBER_H */

/* Use LDAPS implementation */
/* #undef HAVE_LDAP_SSL */

/* Define to 1 if you have the ldap_ssl.h header file. */
/* #undef HAVE_LDAP_SSL_H */

/* Define to 1 if you have the `ldap_url_parse' function. */
/* #undef HAVE_LDAP_URL_PARSE */

/* Define to 1 if you have the <libgen.h> header file. */
#define HAVE_LIBGEN_H 1

/* Define to 1 if you have the `idn2' library (-lidn2). */
/* #undef HAVE_LIBIDN2 */

/* Define to 1 if you have the idn2.h header file. */
/* #undef HAVE_IDN2_H */

/* if zlib is available */
#define HAVE_LIBZ 1

/* if brotli is available */
/* #undef HAVE_BROTLI */

/* if zstd is available */
/* #undef HAVE_ZSTD */

/* Define to 1 if you have the <locale.h> header file. */
#define HAVE_LOCALE_H 1

/* Define to 1 if the compiler supports the 'long long' data type. */
#define HAVE_LONGLONG 1

/* Define to 1 if you have the 'suseconds_t' data type. */
#define HAVE_SUSECONDS_T 1

/* Define to 1 if you have the MSG_NOSIGNAL flag. */
#define HAVE_MSG_NOSIGNAL 1

/* Define to 1 if you have the <netdb.h> header file. */
#define HAVE_NETDB_H 1

/* Define to 1 if you have the <netinet/in.h> header file. */
#define HAVE_NETINET_IN_H 1

/* Define to 1 if you have the <netinet/tcp.h> header file. */
#define HAVE_NETINET_TCP_H 1

/* Define to 1 if you have the <netinet/udp.h> header file. */
#define HAVE_NETINET_UDP_H 1

/* Define to 1 if you have the <linux/tcp.h> header file. */
/* #undef HAVE_LINUX_TCP_H */

/* Define to 1 if you have the <net/if.h> header file. */
#define HAVE_NET_IF_H 1

/* if you have an old MIT gssapi library, lacking GSS_C_NT_HOSTBASED_SERVICE */
/* #undef HAVE_OLD_GSSMIT */

/* Define to 1 if you have the `pipe' function. */
#define HAVE_PIPE 1

/* Define to 1 if you have the `eventfd' function. */
#define HAVE_EVENTFD 1

/* If you have poll */
#define HAVE_POLL 1

/* Define to 1 if you have the <poll.h> header file. */
#define HAVE_POLL_H 1

/* Define to 1 if you have a working POSIX-style strerror_r function. */
/* #undef HAVE_POSIX_STRERROR_R */

/* Define to 1 if you have the <pthread.h> header file */
#define HAVE_PTHREAD_H 1

/* Define to 1 if you have the <pwd.h> header file. */
#define HAVE_PWD_H 1

/* Define to 1 if OpenSSL has the `SSL_set0_wbio` function. */
#define HAVE_SSL_SET0_WBIO 1

/* Define to 1 if you have the recv function. */
#define HAVE_RECV 1

/* Define to 1 if you have the select function. */
#define HAVE_SELECT 1

/* Define to 1 if you have the sched_yield function. */
#define HAVE_SCHED_YIELD 1

/* Define to 1 if you have the send function. */
#define HAVE_SEND 1

/* Define to 1 if you have the sendmsg function. */
#define HAVE_SENDMSG 1

/* Define to 1 if you have the sendmmsg function. */
#define HAVE_SENDMMSG 1

/* Define to 1 if you have the 'fsetxattr' function. */
#define HAVE_FSETXATTR 1

/* fsetxattr() takes 5 args */
#define HAVE_FSETXATTR_5 1

/* fsetxattr() takes 6 args */
/* #undef HAVE_FSETXATTR_6 */

/* Define to 1 if you have the `setlocale' function. */
#define HAVE_SETLOCALE 1

/* Define to 1 if you have the `setmode' function. */
/* #undef HAVE_SETMODE */

/* Define to 1 if you have the `setrlimit' function. */
#define HAVE_SETRLIMIT 1

/* Define to 1 if you have a working setsockopt SO_NONBLOCK function. */
/* #undef HAVE_SETSOCKOPT_SO_NONBLOCK */

/* Define to 1 if you have the sigaction function. */
#define HAVE_SIGACTION 1

/* Define to 1 if you have the siginterrupt function. */
#define HAVE_SIGINTERRUPT 1

/* Define to 1 if you have the signal function. */
#define HAVE_SIGNAL 1

/* Define to 1 if you have the sigsetjmp function or macro. */
#define HAVE_SIGSETJMP 1

/* Define to 1 if you have the `snprintf' function. */
#define HAVE_SNPRINTF 1

/* Define to 1 if struct sockaddr_in6 has the sin6_scope_id member */
#define HAVE_SOCKADDR_IN6_SIN6_SCOPE_ID 1

/* Define to 1 if you have the `socket' function. */
#define HAVE_SOCKET 1

/* Define to 1 if you have the socketpair function. */
#define HAVE_SOCKETPAIR 1

/* Define to 1 if you have the <stdatomic.h> header file. */
#define HAVE_STDATOMIC_H 1

/* Define to 1 if you have the <stdbool.h> header file. */
#define HAVE_STDBOOL_H 1

/* Define to 1 if you have the strcasecmp function. */
#define HAVE_STRCASECMP 1

/* Define to 1 if you have the strcmpi function. */
/* #undef HAVE_STRCMPI */

/* Define to 1 if you have the strdup function. */
#define HAVE_STRDUP 1

/* Define to 1 if you have the strerror_r function. */
/* #undef HAVE_STRERROR_R */

/* Define to 1 if you have the stricmp function. */
/* #undef HAVE_STRICMP */

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <stropts.h> header file. */
/* #undef HAVE_STROPTS_H */

/* Define to 1 if you have the strtok_r function. */
#define HAVE_STRTOK_R 1

/* Define to 1 if you have the strtoll function. */
#define HAVE_STRTOLL 1

/* Define to 1 if you have the memrchr function. */
#define HAVE_MEMRCHR 1

/* if struct sockaddr_storage is defined */
#define HAVE_STRUCT_SOCKADDR_STORAGE 1

/* Define to 1 if you have the timeval struct. */
#define HAVE_STRUCT_TIMEVAL 1

/* Define to 1 if you have the <sys/eventfd.h> header file. */
#define HAVE_SYS_EVENTFD_H 1

/* Define to 1 if you have the <sys/filio.h> header file. */
/* #undef HAVE_SYS_FILIO_H */

/* Define to 1 if you have the <sys/wait.h> header file. */
#define HAVE_SYS_WAIT_H 1

/* Define to 1 if you have the <sys/ioctl.h> header file. */
#define HAVE_SYS_IOCTL_H 1

/* Define to 1 if you have the <sys/param.h> header file. */
#define HAVE_SYS_PARAM_H 1

/* Define to 1 if you have the <sys/poll.h> header file. */
#define HAVE_SYS_POLL_H 1

/* Define to 1 if you have the <sys/resource.h> header file. */
#define HAVE_SYS_RESOURCE_H 1

/* Define to 1 if you have the <sys/select.h> header file. */
#define HAVE_SYS_SELECT_H 1

/* Define to 1 if you have the <sys/socket.h> header file. */
#define HAVE_SYS_SOCKET_H 1

/* Define to 1 if you have the <sys/sockio.h> header file. */
/* #undef HAVE_SYS_SOCKIO_H */

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/time.h> header file. */
#define HAVE_SYS_TIME_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <sys/un.h> header file. */
#define HAVE_SYS_UN_H 1

/* Define to 1 if you have the <sys/utime.h> header file. */
/* #undef HAVE_SYS_UTIME_H */

/* Define to 1 if you have the <termios.h> header file. */
#define HAVE_TERMIOS_H 1

/* Define to 1 if you have the <termio.h> header file. */
#define HAVE_TERMIO_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if you have the `utime' function. */
#define HAVE_UTIME 1

/* Define to 1 if you have the `utimes' function. */
#define HAVE_UTIMES 1

/* Define to 1 if you have the <utime.h> header file. */
#define HAVE_UTIME_H 1

/* Define this symbol if your OS supports changing the contents of argv */
#define HAVE_WRITABLE_ARGV 1

/* Define to 1 if you need the malloc.h header file even with stdlib.h */
/* #undef NEED_MALLOC_H */

/* Define to 1 if _REENTRANT preprocessor symbol must be defined. */
/* #undef NEED_REENTRANT */

/* cpu-machine-OS */
#define OS "Linux"

/* Name of package */
/* #undef PACKAGE */

/* Define to the address where bug reports for this package should be sent. */
/* #undef PACKAGE_BUGREPORT */

/* Define to the full name of this package. */
/* #undef PACKAGE_NAME */

/* Define to the full name and version of this package. */
/* #undef PACKAGE_STRING */

/* Define to the one symbol short name of this package. */
/* #undef PACKAGE_TARNAME */

/* Define to the version of this package. */
/* #undef PACKAGE_VERSION */

/*
 Note: SIZEOF_* variables are fetched with CMake through check_type_size().
 As per CMake documentation on CheckTypeSize, C preprocessor code is
 generated by CMake into SIZEOF_*_CODE. This is what we use in the
 following statements.

 Reference: https://cmake.org/cmake/help/latest/module/CheckTypeSize.html
*/

/* The size of `int', as computed by sizeof. */
#define SIZEOF_INT 4

/* The size of `long', as computed by sizeof. */
#define SIZEOF_LONG 8

/* The size of `long long', as computed by sizeof. */
#define SIZEOF_LONG_LONG 8

/* The size of `off_t', as computed by sizeof. */
#define SIZEOF_OFF_T 8

/* The size of `curl_off_t', as computed by sizeof. */
#define SIZEOF_CURL_OFF_T 8

/* The size of `curl_socket_t', as computed by sizeof. */
#define SIZEOF_CURL_SOCKET_T 4

/* The size of `size_t', as computed by sizeof. */
#define SIZEOF_SIZE_T 8

/* The size of `time_t', as computed by sizeof. */
#define SIZEOF_TIME_T 8

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Define if you want to enable c-ares support */
/* #undef USE_ARES */

/* Define if you want to enable POSIX threaded DNS lookup */
#define USE_THREADS_POSIX 1

/* Define if you want to enable Win32 threaded DNS lookup */
/* #undef USE_THREADS_WIN32 */

/* if GnuTLS is enabled */
/* #undef USE_GNUTLS */

/* if Secure Transport is enabled */
/* #undef USE_SECTRANSP */

/* if mbedTLS is enabled */
/* #undef USE_MBEDTLS */

/* if BearSSL is enabled */
/* #undef USE_BEARSSL */

/* if Rustls is enabled */
/* #undef USE_RUSTLS */

/* if wolfSSL is enabled */
/* #undef USE_WOLFSSL */

/* if wolfSSL has the wolfSSL_DES_ecb_encrypt function. */
/* #undef HAVE_WOLFSSL_DES_ECB_ENCRYPT */

/* if wolfSSL has the wolfSSL_BIO_set_shutdown function. */
/* #undef HAVE_WOLFSSL_FULL_BIO */

/* if libssh is in use */
/* #undef USE_LIBSSH */

/* if libssh2 is in use */
/* #undef USE_LIBSSH2 */

/* if wolfssh is in use */
/* #undef USE_WOLFSSH */

/* if libpsl is in use */
/* #undef USE_LIBPSL */

/* if you want to use OpenLDAP code instead of legacy ldap implementation */
/* #undef USE_OPENLDAP */

/* if OpenSSL is in use */
/* #undef USE_OPENSSL */

/* if librtmp/rtmpdump is in use */
/* #undef USE_LIBRTMP */

/* if GSASL is in use */
/* #undef USE_GSASL */

/* if libuv is in use */
/* #undef USE_LIBUV */

/* Define to 1 if you have the <uv.h> header file. */
/* #undef HAVE_UV_H */

/* Define to 1 if you do not want the OpenSSL configuration to be loaded
   automatically */
/* #undef CURL_DISABLE_OPENSSL_AUTO_LOAD_CONFIG */

/* to enable NGHTTP2  */
/* #undef USE_NGHTTP2 */

/* to enable NGTCP2 */
/* #undef USE_NGTCP2 */

/* to enable NGHTTP3  */
/* #undef USE_NGHTTP3 */

/* to enable quiche */
/* #undef USE_QUICHE */

/* to enable openssl + nghttp3 */
/* #undef USE_OPENSSL_QUIC */

/* Define to 1 if you have the quiche_conn_set_qlog_fd function. */
/* #undef HAVE_QUICHE_CONN_SET_QLOG_FD */

/* to enable msh3 */
/* #undef USE_MSH3 */

/* if Unix domain sockets are enabled  */
#define USE_UNIX_SOCKETS 1

/* Define to 1 if you are building a Windows target with large file support. */
/* #undef USE_WIN32_LARGE_FILES */

/* to enable SSPI support */
/* #undef USE_WINDOWS_SSPI */

/* to enable Windows SSL  */
/* #undef USE_SCHANNEL */

/* enable multiple SSL backends */
/* #undef CURL_WITH_MULTI_SSL */

/* Version number of package */
/* #undef VERSION */

/* Number of bits in a file offset, on hosts where this is settable. */
#define _FILE_OFFSET_BITS 64

/* Define for large files, on AIX-style hosts. */
/* #undef _LARGE_FILES */

/* define this if you need it to compile thread-safe code */
/* #undef _THREAD_SAFE */

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Type to use in place of in_addr_t when system does not provide it. */
/* #undef in_addr_t */

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */

/* the signed version of size_t */
/* #undef ssize_t */

/* Define to 1 if you have the mach_absolute_time function. */
/* #undef HAVE_MACH_ABSOLUTE_TIME */

/* to enable Windows IDN */
/* #undef USE_WIN32_IDN */

/* to enable Apple IDN */
/* #undef USE_APPLE_IDN */

/* Define to 1 if OpenSSL has the SSL_CTX_set_srp_username function. */
#define HAVE_OPENSSL_SRP 1

/* Define to 1 if GnuTLS has the gnutls_srp_verifier function. */
/* #undef HAVE_GNUTLS_SRP */

/* Define to 1 to enable TLS-SRP support. */
#define USE_TLS_SRP 1

/* Define to 1 to query for HTTPSRR when using DoH */
/* #undef USE_HTTPSRR */

/* if ECH support is available */
/* #undef USE_ECH */

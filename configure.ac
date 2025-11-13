#!/bin/bash -norc
dnl	This file is an input file used by the GNU "autoconf" program to
dnl	generate the file "configure", which is run during Tcl installation
dnl	to configure the system for the local environment.

#-----------------------------------------------------------------------
# Sample configure.ac for Tcl Extensions.  The only places you should
# need to modify this file are marked by the string __CHANGE__
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# __CHANGE__
# Set your package name and version numbers here.
#
# This initializes the environment with PACKAGE_NAME and PACKAGE_VERSION
# set as provided.  These will also be added as -D defs in your Makefile
# so you can encode the package version directly into the source files.
# This will also define a special symbol for Windows (BUILD_<PACKAGE_NAME>
# so that we create the export library with the dll.
#-----------------------------------------------------------------------

AC_INIT([tclreadline],[2.4.1])

#--------------------------------------------------------------------
# Call TEA_INIT as the first TEA_ macro to set up initial vars.
# This will define a ${TEA_PLATFORM} variable == "unix" or "windows"
# as well as PKG_LIB_FILE and PKG_STUB_LIB_FILE.
#--------------------------------------------------------------------

TEA_INIT()

AC_CONFIG_AUX_DIR(tclconfig)

#--------------------------------------------------------------------
# Load the tclConfig.sh file
#--------------------------------------------------------------------

TEA_PATH_TCLCONFIG
TEA_LOAD_TCLCONFIG

#--------------------------------------------------------------------
# Load the tkConfig.sh file if necessary (Tk extension)
#--------------------------------------------------------------------

# Handle --without-tk by setting no_tk before TEA_PATH_TKCONFIG runs
# This prevents the error when tkConfig.sh is not found
AC_ARG_WITH([tk])
if test "$with_tk" = "no"; then
    no_tk=true
fi

TEA_PATH_TKCONFIG
if test "$no_tk" != "true"; then
    TEA_LOAD_TKCONFIG
fi

#-----------------------------------------------------------------------
# Handle the --prefix=... option by defaulting to what Tcl gave.
# Must be called after TEA_LOAD_TCLCONFIG and before TEA_SETUP_COMPILER.
#-----------------------------------------------------------------------

TEA_PREFIX

#-----------------------------------------------------------------------
# Standard compiler checks.
# This sets up CC by using the CC env var, or looks for gcc otherwise.
# This also calls AC_PROG_CC and a few others to create the basic setup
# necessary to compile executables.
#-----------------------------------------------------------------------

TEA_SETUP_COMPILER

HIGHEST_C_STANDARD
CFLAGS="$C_STD_CFLAGS $CFLAGS"

MAJOR=`echo $PACKAGE_VERSION | cut -d. -f 1`
MINOR=`echo $PACKAGE_VERSION | cut -d. -f 2`
PATCHLEVEL=`echo $PACKAGE_VERSION | cut -d. -f 3`
VERSION=$MAJOR.$MINOR
PATCHLEVEL_STR=$VERSION.$PATCHLEVEL

AC_SUBST(MAJOR)
AC_SUBST(MINOR)
AC_SUBST(PATCHLEVEL)
AC_SUBST(VERSION)
AC_SUBST(PATCHLEVEL_STR)

#-----------------------------------------------------------------------
# __CHANGE__
# Specify the C source files to compile in TEA_ADD_SOURCES,
# public headers that need to be installed in TEA_ADD_HEADERS,
# stub library C source files to compile in TEA_ADD_STUB_SOURCES,
# and runtime Tcl library files in TEA_ADD_TCL_SOURCES.
# This defines PKG(_STUB)_SOURCES, PKG(_STUB)_OBJECTS, PKG_HEADERS
# and PKG_TCL_SOURCES.
#-----------------------------------------------------------------------

#--------------------------------------------------------------------
# Allow user to override readline location
#--------------------------------------------------------------------

AC_ARG_WITH([readline-includes],
    [AS_HELP_STRING([--with-readline-includes=DIR],
        [directory containing readline headers (default: from pkg-config)])],
    [readline_includes=$withval],
    [readline_includes=auto])

AC_ARG_WITH([readline-library],
    [AS_HELP_STRING([--with-readline-library=lib spec],
        [lib spec to readline (e.g. '-L/usr/local/lib -lreadline') (default: from pkg-config)])],
    [readline_library=$withval],
    [readline_library=auto])

# Get readline build flags from pkg-config or user-specified paths
if test "$readline_includes" == "auto"; then
	READLINE_CFLAGS=`pkg-config --cflags readline 2>/dev/null || echo ""`
else
	READLINE_CFLAGS="-I$readline_includes"
fi

if test "$readline_library" == "auto"; then
	READLINE_LIBS=`pkg-config --libs readline 2>/dev/null || echo "-lreadline"`
else
	READLINE_LIBS="-L$readline_library -lreadline"
fi

AC_MSG_CHECKING([for readline compiler flags])
AC_MSG_RESULT([$READLINE_CFLAGS])
AC_MSG_CHECKING([for readline linker flags])
AC_MSG_RESULT([$READLINE_LIBS])

#--------------------------------------------------------------------
# Determine highest C standard and check for C23 features
#--------------------------------------------------------------------

TEA_ADD_SOURCES([generic/tclreadline.c generic/tclreadlineBuildInfo.c])
TEA_ADD_HEADERS([])
TEA_ADD_INCLUDES([])
TEA_ADD_LIBS([${READLINE_LIBS}])
TEA_ADD_CFLAGS([${C_STD_CFLAGS} ${READLINE_CFLAGS}])
TEA_ADD_STUB_SOURCES([])
TEA_ADD_TCL_SOURCES([library/tclreadlineSetup.tcl library/tclreadlineCompleter.tcl])

#--------------------------------------------------------------------
# __CHANGE__
#
# You can add more files to clean if your extension creates any extra
# files by extending CLEANFILES.
# Add pkgIndex.tcl if it is generated in the Makefile instead of ./configure
# and change Makefile.in to move it from CONFIG_CLEAN_FILES to BINARIES var.
#
# A few miscellaneous platform-specific items:
# TEA_ADD_* any platform specific compiler/build info here.
#--------------------------------------------------------------------

#CLEANFILES="$CLEANFILES pkgIndex.tcl"
if test "${TEA_PLATFORM}" = "windows" ; then
    # Ensure no empty if clauses
    :
    #TEA_ADD_SOURCES([win/winFile.c])
    #TEA_ADD_INCLUDES([-I\"$(${CYGPATH} ${srcdir}/win)\"])
else
    # Ensure no empty else clauses
    :
    #TEA_ADD_SOURCES([unix/unixFile.c])
    #TEA_ADD_LIBS([-lsuperfly])
fi

#--------------------------------------------------------------------
# __CHANGE__
# Choose which headers you need.  Extension authors should try very
# hard to only rely on the Tcl public header files.  Internal headers
# contain private data structures and are subject to change without
# notice.
# This MUST be called after TEA_LOAD_TCLCONFIG / TEA_LOAD_TKCONFIG
#--------------------------------------------------------------------

TEA_PUBLIC_TCL_HEADERS
#TEA_PRIVATE_TCL_HEADERS

if test "$no_tk" != "true"; then
    TEA_PUBLIC_TK_HEADERS
    #TEA_PRIVATE_TK_HEADERS
fi
#TEA_PATH_X

#--------------------------------------------------------------------
# Check whether --enable-threads or --disable-threads was given.
# This auto-enables if Tcl was compiled threaded.
#--------------------------------------------------------------------

TEA_ENABLE_THREADS

#--------------------------------------------------------------------
# The statement below defines a collection of symbols related to
# building as a shared library instead of a static library.
#--------------------------------------------------------------------

TEA_ENABLE_SHARED

#--------------------------------------------------------------------
# This macro figures out what flags to use with the compiler/linker
# when building shared/static debug/optimized objects.  This information
# can be taken from the tclConfig.sh file, but this figures it all out.
#--------------------------------------------------------------------

TEA_CONFIG_CFLAGS

#--------------------------------------------------------------------
# Set the default compiler switches based on the --enable-symbols option.
#--------------------------------------------------------------------

TEA_ENABLE_SYMBOLS

#--------------------------------------------------------------------
# This macro generates a line to use when building a library.  It
# depends on values set by the TEA_ENABLE_SHARED, TEA_ENABLE_SYMBOLS,
# and TEA_LOAD_TCLCONFIG macros above.
#--------------------------------------------------------------------

TEA_MAKE_LIB

#--------------------------------------------------------------------
# Determine the name of the tclsh and/or wish executables in the
# Tcl and Tk build directories or the location they were installed
# into. These paths are used to support running test cases only,
# the Makefile should not be making use of these paths to generate
# a pkgIndex.tcl file or anything else at extension build time.
#--------------------------------------------------------------------

TEA_PROG_TCLSH
#TEA_PROG_WISH


AC_CHECK_HEADERS([string.h])

#--------------------------------------------------------------------
# Do we have sigaction?
#--------------------------------------------------------------------

AC_CHECK_FUNCS([sigaction])

#--------------------------------------------------------------------
# Can we embed data in object files with objcopy?
#--------------------------------------------------------------------
CHECK_EMBED_BINARY

#--------------------------------------------------------------------
# Check for readline features
# Use the same flags that will be used for building (PKG_LIBS, PKG_CFLAGS)
#--------------------------------------------------------------------

# Save LIBS and CFLAGS, then add the package build flags for feature detection
# Note: We need to expand CFLAGS variables that TEA_CONFIG_CFLAGS set as makefile variables
SAVE_LIBS="$LIBS"
SAVE_CFLAGS="$CFLAGS"
LIBS="$LIBS ${PKG_LIBS} ${TCL_LIB_SPEC}"
# Expand the makefile variables in CFLAGS for use in compile tests
eval "EXPANDED_CFLAGS=\"$CFLAGS\""
#CFLAGS="$EXPANDED_CFLAGS $PKG_INCLUDES $TCL_INCLUDES ${PKG_CFLAGS}"
CFLAGS="$TCL_INCLUDE_SPEC $EXPANDED_CFLAGS $PKG_INCLUDES ${PKG_CFLAGS}"

# Check for readline's rl_executing_macro or _rl_executing_macro
# (could be macro.c's private variable _rl_executing_macro)
AC_MSG_CHECKING([for rl_executing_macro in -lreadline])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[
    #include <stdio.h>
    #include <readline/readline.h>
    extern char* rl_executing_macro;
]], [[
    rl_executing_macro = (char*) 0;
]])],
[AC_MSG_RESULT(yes)
 AC_DEFINE(EXECUTING_MACRO_NAME, rl_executing_macro,
     [Define to the name of the executing macro variable in libreadline.])],
[AC_MSG_RESULT(no)
 # Try the private _rl_executing_macro variable
 AC_MSG_CHECKING([for _rl_executing_macro in -lreadline])
 AC_LINK_IFELSE([AC_LANG_PROGRAM([[
     #include <stdio.h>
     #include <readline/readline.h>
     extern char* _rl_executing_macro;
 ]], [[
     _rl_executing_macro = (char*) 0;
 ]])],
 [AC_MSG_RESULT(yes)
  AC_DEFINE(EXECUTING_MACRO_HACK, 1,
      [Define if EXECUTING_MACRO_NAME is resolved in libreadline.])
  AC_DEFINE(EXECUTING_MACRO_NAME, _rl_executing_macro,
      [Define to the name of the executing macro variable in libreadline.])],
 [AC_MSG_RESULT(no)])])

# Check for readline's rl_cleanup_after_signal
AC_MSG_CHECKING([for rl_cleanup_after_signal() in -lreadline])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[
    #include <stdio.h>
    #include <readline/readline.h>
    extern void rl_cleanup_after_signal(void);
]], [[
    rl_cleanup_after_signal();
]])],
[AC_MSG_RESULT(yes)
 AC_DEFINE(CLEANUP_AFTER_SIGNAL, 1,
     [Define if rl_cleanup_after_signal is resolved in libreadline.])],
[AC_MSG_RESULT(no)])

# Check for readline's rl_extend_line_buffer
AC_MSG_CHECKING([for rl_extend_line_buffer() in -lreadline])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[
    #include <stdio.h>
    #include <readline/readline.h>
    extern void rl_extend_line_buffer(int len);
]], [[
    rl_extend_line_buffer(1);
]])],
[AC_MSG_RESULT(yes)
 AC_DEFINE(EXTEND_LINE_BUFFER, 1,
     [Define if rl_extend_line_buffer is resolved in libreadline.])],
[AC_MSG_RESULT(no)])

# Check for the readline version number
AC_MSG_CHECKING([for the readline version number])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[
    #include <stdio.h>
    #include <readline/readline.h>
    extern const char *rl_library_version;
]], [[
    const char *version = rl_library_version;
    (void)version;
]])],
[AC_MSG_RESULT([runtime detection])
 AC_DEFINE(HAVE_RL_LIBRARY_VERSION, 1,
     [Define if rl_library_version is available in libreadline.])],
[AC_MSG_RESULT(no)])

CHECK_C23_EMBED
CHECK_ZIPFS
CHECK_EMBED_BINARY
CHECK_TCL_STATICLIBRARY

# Define constants for each embedding method
AC_DEFINE([EMBED_METHOD_C23_EMBED], [1], [C23 #embed directive])
AC_DEFINE([EMBED_METHOD_ZIPFS], [2], [Tcl zipfs])
AC_DEFINE([EMBED_METHOD_OBJCOPY], [3], [objcopy binary embedding])
AC_DEFINE([EMBED_METHOD_TCL_FINDLIBRARY], [4], [Runtime Tcl library search])

# Allow override of embedding method for testing
AC_ARG_WITH([initscripts-method],
    [AS_HELP_STRING([--with-initscripts-method=METHOD],
        [force specific method for loading init scripts (c23_embed, zipfs, objcopy, or tcl_findLibrary)])],
    [with_initscripts_method=$withval],
    [with_initscripts_method=auto])

# Determine embedding method priority: C23 > zipfs > objcopy
AC_MSG_CHECKING([for method to load init scripts])
if test "$with_initscripts_method" != "auto"; then
    # User specified a method - validate and use it
    case "$with_initscripts_method" in
        c23_embed)
            if test "$have_c23_embed" = "yes"; then
                USE_EMBED_METHOD=c23_embed
                USE_EMBED_METHOD_VALUE=1
            else
                AC_MSG_ERROR([--with-initscripts-method=c23_embed requested but C23 @%:@embed not supported])
            fi
            ;;
        zipfs)
            if test "$have_zipfs" = "yes"; then
                USE_EMBED_METHOD=zipfs
                USE_EMBED_METHOD_VALUE=2
            else
                AC_MSG_ERROR([--with-initscripts-method=zipfs requested but zipfs not available])
            fi
            ;;
        objcopy)
            if test "$have_embed_binary" = "yes"; then
                USE_EMBED_METHOD=objcopy
                USE_EMBED_METHOD_VALUE=3
            else
                AC_MSG_ERROR([--with-initscripts-method=objcopy requested but objcopy embedding not supported])
            fi
            ;;
        tcl_findLibrary)
            USE_EMBED_METHOD=tcl_findLibrary
            USE_EMBED_METHOD_VALUE=4
            ;;
        *)
            AC_MSG_ERROR([--with-initscripts-method must be one of: c23_embed, zipfs, objcopy, tcl_findLibrary])
            ;;
    esac
else
    # Auto-detect best available method
    if test "$have_c23_embed" = "yes"; then
        USE_EMBED_METHOD=c23_embed
        USE_EMBED_METHOD_VALUE=1
    elif test "$have_zipfs" = "yes"; then
        USE_EMBED_METHOD=zipfs
        USE_EMBED_METHOD_VALUE=2
    elif test "$have_embed_binary" = "yes"; then
        USE_EMBED_METHOD=objcopy
        USE_EMBED_METHOD_VALUE=3
    else
        USE_EMBED_METHOD=tcl_findLibrary
        USE_EMBED_METHOD_VALUE=4
    fi
fi
AC_MSG_RESULT([$USE_EMBED_METHOD])
AC_SUBST(USE_EMBED_METHOD)
AC_DEFINE_UNQUOTED([USE_EMBED_METHOD], [$USE_EMBED_METHOD_VALUE],
    [Method used to load init scripts])

# Restore LIBS and CFLAGS
LIBS="$SAVE_LIBS"
CFLAGS="$SAVE_CFLAGS"

#--------------------------------------------------------------------
# Options to build statically-linked standalone applications
#--------------------------------------------------------------------

AC_ARG_ENABLE([tclshrl],
    [AS_HELP_STRING([--enable-tclshrl],
        [build statically-linked tclshrl standalone application])],
    [enable_tclshrl=$enableval],
    [enable_tclshrl=no])

AC_ARG_ENABLE([wishrl],
    [AS_HELP_STRING([--enable-wishrl],
        [build statically-linked wishrl standalone application (requires Tk)])],
    [enable_wishrl=$enableval],
    [enable_wishrl=no])

# Check if wishrl was requested but Tk is not available
if test "$enable_wishrl" = "yes" -a "$no_tk" = "true"; then
    AC_MSG_ERROR([--enable-wishrl requires Tk, but --without-tk was specified or Tk was not found])
fi

# Set up variables for Makefile
TCLSHRL_BINARIES=""
WISHRL_BINARIES=""

if test "$enable_tclshrl" = "yes"; then
    TCLSHRL_BINARIES="tclshrl\$(EXEEXT)"
fi

if test "$enable_wishrl" = "yes"; then
    WISHRL_BINARIES="wishrl\$(EXEEXT)"
fi

AC_SUBST(TCLSHRL_BINARIES)
AC_SUBST(WISHRL_BINARIES)

#--------------------------------------------------------------------
# Setup a *Config.sh.in configuration file.
#--------------------------------------------------------------------

#TEA_EXPORT_CONFIG([sample])
#AC_SUBST(SAMPLE_VAR)

#--------------------------------------------------------------------
# Specify files to substitute AC variables in. You may alternatively
# have a special pkgIndex.tcl.in or other files which require
# substituting the AC variables in. Include these here.
#--------------------------------------------------------------------

AC_CONFIG_FILES([Makefile pkgIndex.tcl generic/tclreadline.h doc/tclreadline.n library/tclreadlineInit.tcl])
#AC_CONFIG_FILES([sampleConfig.sh])
AC_CONFIG_HEADERS([generic/config.h])

#--------------------------------------------------------------------
# Finally, substitute all of the various values into the files
# specified with AC_CONFIG_FILES.
#--------------------------------------------------------------------

AC_SUBST(TCL_INCLUDE_SPEC)

AC_OUTPUT

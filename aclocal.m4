#
# Include the TEA standard macro set
#

builtin(include,tclconfig/tcl.m4)

#
# Add here whatever m4 macros you want to define for your package
#

#------------------------------------------------------------------------
# HIGHEST_C_STANDARD
#
#   Determines the highest C standard supported by the compiler.
#   Tests standards in descending order: C23, C17, C11, C99, C90.
#
# Arguments:
#   None
#
# Results:
#   Sets the following variables:
#     C_STD_CFLAGS - Compiler flags for the highest supported standard
#     C_STD_VERSION - The highest supported standard (e.g., "c23", "c17")
#------------------------------------------------------------------------
AC_DEFUN([HIGHEST_C_STANDARD], [
    AC_MSG_CHECKING([for highest supported C standard])

    # Save current CFLAGS
    SAVE_CFLAGS_STD="$CFLAGS"
    SAVE_LIBS_STD="$LIBS"
    LIBS=""

    # Test standards in descending order
    for std in c23 c17 c11 c99 c90; do
        CFLAGS="-std=$std"
        AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[]])], [
            C_STD_VERSION="$std"
            C_STD_CFLAGS="-std=$std"
            break
        ], [])
    done

    # Restore CFLAGS and LIBS
    CFLAGS="$SAVE_CFLAGS_STD"
    LIBS="$SAVE_LIBS_STD"

    if test -n "$C_STD_VERSION"; then
        AC_MSG_RESULT([$C_STD_VERSION])
    else
        AC_MSG_RESULT([none, using compiler default])
        C_STD_CFLAGS=""
        C_STD_VERSION="default"
    fi

    AC_SUBST(C_STD_CFLAGS)
    AC_SUBST(C_STD_VERSION)
])

#------------------------------------------------------------------------
# CHECK_BUILD_TCLSH
#
#  Checks if the build environment can run the Tcl shell (tclsh)
#
# Arguments:
#   None
#
# Results:
#   Sets HAVE_BUILD_TCLSH to "yes" or "no"
#   Sets BUILD_TCLSH to the path of the tclsh program (if HAVE_BUILD_TCLSH is "yes")
#------------------------------------------------------------------------
AC_DEFUN([CHECK_BUILD_TCLSH], [
    AC_MSG_CHECKING([whether the build environment can run tcl scripts])
    HAVE_BUILD_TCLSH=no

    if test -n "$BUILD_TCLSH"; then
        try_tclsh=$BUILD_TCLSH
    elif test -x "$TCLSH_PROG"; then
        try_tclsh=$TCLSH_PROG
    else
        try_tclsh=$(which tclsh 2>/dev/null)
    fi

    if test "$(echo "puts working" | "$try_tclsh" 2>&5)" = "working"; then
        HAVE_BUILD_TCLSH=yes
        BUILD_TCLSH=$try_tclsh
        AC_SUBST(BUILD_TCLSH)
    fi
    AC_MSG_RESULT([$HAVE_BUILD_TCLSH: ${BUILD_TCLSH:-not found}])
    AC_SUBST(HAVE_BUILD_TCLSH)
])

#------------------------------------------------------------------------
#
# TCL_SCRIPT_IFELSE
#
#  Runs a Tcl script and executes one of two code blocks depending on success
#  and whether a TCLSH is available in the build environment (as determined by
#  CHECK_BUILD_TCLSH).
#
# Arguments:
#  $1 - Tcl script to run
#  $2 - Code block to execute if the script succeeds
#  $3 - Code block to execute if the script fails
#
# Results:
#  Executes the appropriate code block
#------------------------------------------------------------------------
AC_DEFUN([TCL_SCRIPT_IFELSE], [[
    prog="if {[catch {$1} e]} {puts stderr \$e; exit 1}"
    if test $HAVE_BUILD_TCLSH = "yes" && echo "$prog" | "$BUILD_TCLSH" 2>&5; then
        eval "$2"
    else
        echo "failed tcl script was:" >&5
        echo "$prog" >&5
        eval "$3"
    fi
]])

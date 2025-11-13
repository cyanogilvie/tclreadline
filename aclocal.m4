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
        AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[]])],
            [C_STD_VERSION="$std"
             C_STD_CFLAGS="-std=$std"
             break],
            [])
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
# CHECK_C23_EMBED
#
#   Checks if the compiler supports the C23 #embed directive.
#
# Arguments:
#   None
#
# Results:
#   Defines HAVE_C23_EMBED if #embed is supported
#------------------------------------------------------------------------
AC_DEFUN([CHECK_C23_EMBED], [
    AC_MSG_CHECKING([if compiler supports @%:@embed directive])

    # Create a temporary test file to embed
    echo "test" > conftest_embed.txt

    AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
        const char embedded_data@<:@@:>@ = {
        @%:@embed "conftest_embed.txt"
        , 0
        };
        int main(void) { return 0; }
    ]])],
    [AC_MSG_RESULT([yes])
     AC_DEFINE([HAVE_C23_EMBED], [1],
         [Define if compiler supports C23 @%:@embed directive])
     have_c23_embed=yes],
    [AC_MSG_RESULT([no])
     have_c23_embed=no])

    # Clean up
    rm -f conftest_embed.txt
])

AC_DEFUN([CHECK_ZIPFS], [
    AC_MSG_CHECKING([for zipfs support in Tcl])
    AC_LINK_IFELSE([AC_LANG_SOURCE([[
        #undef USE_TCL_STUBS 
        #include <tcl.h>
        int main(void) { TclZipfs_Mount(NULL, NULL, NULL, NULL); return 0; }
    ]])],
    [AC_MSG_RESULT([yes])
     AC_DEFINE([HAVE_ZIPFS], [1],
         [Define if Tcl has zipfs support])
     have_zipfs=yes],
    [AC_MSG_RESULT([no])
     have_zipfs=no])
])

AC_DEFUN([CHECK_EMBED_BINARY], [
    # Check if objcopy is available
    AC_CHECK_TOOL([OBJCOPY], [objcopy], [no])

    AC_MSG_CHECKING([whether the toolchain supports embedding files in objects])

    if test "$OBJCOPY" != "no"; then
        # Step 1: Create an empty object file
        if $CC -x c -c -o conftest_embed.o /dev/null >&5; then
            # Step 2: Try to embed data using objcopy
            if echo -ne 'working\0' | $OBJCOPY --add-section .embed=/dev/stdin \
                --set-section-flags .embed=data,alloc,load \
                --add-symbol _embed_data=.embed:0,global,object \
                conftest_embed.o 2>&5; then

                # Step 3: Try to compile and link a test program that uses the embedded data
                cat > conftest_embed_test.c <<"EOF"
#include <string.h>
extern const char _embed_data;
const char* embed_data = &_embed_data;
int main(void) {
    return strcmp(embed_data, "working") != 0;
}
EOF
                if $CC -o conftest_embed_test$EXEEXT conftest_embed.o conftest_embed_test.c 2>&5 >&5; then
                    # Step 4: Try to run the test program (if not cross-compiling)
                    if test "$cross_compiling" != "yes"; then
                        if ./conftest_embed_test$EXEEXT >&5; then
                            AC_MSG_RESULT([yes])
                            AC_DEFINE([HAVE_EMBED_BINARY], [1],
                                [Define if toolchain supports objcopy embedding])
                            have_embed_binary=yes
                        else
                            AC_MSG_RESULT([no (runtime test failed)])
                            have_embed_binary=no
                        fi
                    else
                        # Cross-compiling: assume it works if we got this far
                        AC_MSG_RESULT([yes (cross-compiling, assumed)])
                        AC_DEFINE([HAVE_EMBED_BINARY], [1],
                            [Define if toolchain supports objcopy embedding])
                        have_embed_binary=yes
                    fi
                else
                    AC_MSG_RESULT([no (linking failed)])
                    have_embed_binary=no
                fi
            else
                AC_MSG_RESULT([no (objcopy failed)])
                have_embed_binary=no
            fi
        else
            AC_MSG_RESULT([no (compilation failed)])
            have_embed_binary=no
        fi
    else
        AC_MSG_RESULT([no (objcopy not found)])
        have_embed_binary=no
    fi

    # Clean up
    #rm -f conftest_embed.o conftest_embed_test.c conftest_embed_test$EXEEXT
    rm -f conftest_embed.o conftest_embed_test.c conftest_embed_test$EXEEXT

    AC_SUBST(OBJCOPY)
])

AC_DEFUN([CHECK_TCL_STATICLIBRARY], [
    AC_MSG_CHECKING([whether Tcl_StaticPackage is spelled Tcl_StaticLibrary in this Tcl])
    AC_LINK_IFELSE([AC_LANG_SOURCE([[
        #undef USE_TCL_STUBS
        #include <tcl.h>
        int main(void) { Tcl_StaticLibrary(NULL, NULL, NULL, NULL); return 0; }
    ]])],
    [AC_MSG_RESULT([yes])
     AC_DEFINE([HAVE_TCL_STATICLIBRARY], [1],
         [Define if Tcl has zipfs support])
     have_tcl_staticlibrary=yes],
    [AC_MSG_RESULT([no])
     have_tcl_staticlibrary=no])
])


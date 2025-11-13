 /* ================================================================== *
  * FILE: shrl.c
  * $Id$
  * ---
  * tclreadline -- gnu readline for tcl
  * https://github.com/flightaware/tclreadline/
  * Copyright (c) 1998 - 2014, Johannes Zellner <johannes@zellner.org>
  * This software is copyright under the BSD license.
  * ================================================================== */

#include "tclreadline.h"
#include <stdlib.h>
#include <string.h>
#if IS_WISHRL
#include <tk.h>
#endif

#if USE_EMBED_METHOD == EMBED_METHOD_C23_EMBED
static const char initscript[] = {
#embed "../library/tclreadlineInit.tcl"
    ,0
};

static const char setupscript[] = {
#embed "../library/tclreadlineSetup.tcl"
    ,0
};

static const char completerscript[] = {
#embed "../library/tclreadlineCompleter.tcl"
    ,0
};
#elif USE_EMBED_METHOD == EMBED_METHOD_OBJCOPY
extern const char _TclReadlineInitScript_tclreadlineInit_tcl;
const char* initscript = &_TclReadlineInitScript_tclreadlineInit_tcl;

extern const char _TclReadlineInitScript_tclreadlineSetup_tcl;
const char* setupscript = &_TclReadlineInitScript_tclreadlineSetup_tcl;

extern const char _TclReadlineInitScript_tclreadlineCompleter_tcl;
const char* completerscript = &_TclReadlineInitScript_tclreadlineCompleter_tcl;
#endif

int
TclreadlineAppInit(Tcl_Interp* interp)
{
    if (
        TCL_OK != Tcl_Init(interp) ||
#if IS_WISHRL
        TCL_OK != Tk_Init(interp) ||
#endif
        TCL_OK != Tclreadline_Init(interp)
    ) return TCL_ERROR;

#if HAVE_TCL_STATICLIBRARY
#   define STATICLIBRARY Tcl_StaticLibrary
#else
#   define STATICLIBRARY Tcl_StaticPackage
#endif
    STATICLIBRARY(interp, "tclreadline", Tclreadline_Init, Tclreadline_SafeInit);

    Tcl_SetVar(interp, "tcl_rcFileName", "~/.tclshrc", TCL_GLOBAL_ONLY);

#if USE_EMBED_METHOD == EMBED_METHOD_C23_EMBED || USE_EMBED_METHOD == EMBED_METHOD_OBJCOPY
#   define X(name, file) \
        if (TCL_OK != Tcl_EvalEx(interp, name, -1, TCL_EVAL_GLOBAL|TCL_EVAL_DIRECT)) { \
            Tcl_SetObjResult(interp, \
                    Tcl_ObjPrintf("(TclreadlineAppInit) unable to eval %s: %s", \
                        file, Tcl_GetStringResult(interp))); \
            return TCL_ERROR; \
        }
#elif USE_EMBED_METHOD == EMBED_METHOD_ZIPFS
    //Tcl_EvalEx(interp, "zipfs mount [info nameofexecutable] //zipfs:/app", -1, TCL_EVAL_GLOBAL|TCL_EVAL_DIRECT);
#   define X(name, file) \
        if (TCL_OK != Tcl_EvalFile(interp, "//zipfs:/app/" file)) { \
            Tcl_SetObjResult(interp, \
                    Tcl_ObjPrintf("(TclreadlineAppInit) unable to source %s: %s", \
                        file, Tcl_GetStringResult(interp))); \
            return TCL_ERROR; \
        }
#elif USE_EMBED_METHOD == EMBED_METHOD_TCL_FINDLIBRARY
    /* Use tcl_findLibrary to locate and source the init script, which sets tclreadline_library */
    if (TCL_OK != Tcl_EvalEx(interp,
            "if {[file readable [file join [pwd] library tclreadlineInit.tcl]]} {set ::tclreadline::library [file join [pwd] library]}\n"
            "tcl_findLibrary tclreadline " TCLRL_VERSION_STR " " TCLRL_PATCHLEVEL_STR " "
            "tclreadlineInit.tcl TCLREADLINE_LIBRARY ::tclreadline::library",
            -1, TCL_EVAL_GLOBAL|TCL_EVAL_DIRECT)) {
        Tcl_SetObjResult(interp,
                Tcl_ObjPrintf("(TclreadlineAppInit) tcl_findLibrary failed: %s",
                    Tcl_GetStringResult(interp)));
        return TCL_ERROR;
    }
    Tcl_EvalEx(interp, "set tclreadline_library $::tclreadline::library",
            -1, TCL_EVAL_GLOBAL|TCL_EVAL_DIRECT);

    /* Source remaining scripts from the library directory */
#   define X(name, file) \
        if (strcmp(file, "tclreadlineInit.tcl") != 0 && TCL_OK != Tcl_EvalEx(interp, \
                "source [file join $tclreadline_library " file "]", \
                -1, TCL_EVAL_GLOBAL|TCL_EVAL_DIRECT)) { \
            Tcl_SetObjResult(interp, \
                    Tcl_ObjPrintf("(TclreadlineAppInit) unable to source %s: %s", \
                        file, Tcl_GetStringResult(interp))); \
            return TCL_ERROR; \
        }
#else
#   error "No valid EMBED_METHOD defined"
#endif

#define INIT_SCRIPTS \
        X(initscript,       "tclreadlineInit.tcl") \
        X(setupscript,      "tclreadlineSetup.tcl") \
        X(completerscript,  "tclreadlineCompleter.tcl")

    INIT_SCRIPTS

#undef X
#undef INIT_SCRIPTS

    return TCL_OK;
}

int
main(int argc, char *argv[])
{
#if HAVE_ZIPFS
    TclZipfs_AppHook(&argc, &argv);
#endif

#if IS_WISHRL
    Tk_Main(argc, argv, TclreadlineAppInit);
#else
    Tcl_Main(argc, argv, TclreadlineAppInit);
#endif
    return EXIT_SUCCESS;
}

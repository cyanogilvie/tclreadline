# FILE: tclreadlineInit.tcl.in
# $Id$
# ---
# tclreadline -- gnu readline for tcl
# https://github.com/flightaware/tclreadline/
# Copyright (c) 1998 - 2014, Johannes Zellner <johannes@zellner.org>
# This software is copyright under the BSD license.
# ---

# Only run by tclshrl and wishrl
package provide tclreadline 2.4.1
::tclreadline::readline customcompleter ::tclreadline::ScriptCompleter

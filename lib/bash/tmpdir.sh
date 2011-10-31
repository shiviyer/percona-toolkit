# This program is copyright 2011 Percona Inc.
# Feedback and improvements are welcome.
#
# THIS PROGRAM IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, version 2; OR the Perl Artistic License.  On UNIX and similar
# systems, you can issue `man perlgpl' or `man perlartistic' to read these
# licenses.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA.
# ###########################################################################
# tmpdir package
# ###########################################################################

# Package: tmpdir
# tmpdir make a secure temporary directory using mktemp.

set -u

# Global variables.
TMPDIR=""
OPT_TMPDIR=${OPT_TMPDIR:""}

# Sub: set_TMPDIR
#   Create a secure tmpdir and set TMPDIR.
#
# Optional Global Variables:
#   OPT_TMPDIR - User-specified --tmpdir (default none).
#
# Set Global Variables:
#   TMPDIR - Absolute path of secure temp directory.
set_TMPDIR() {
   if [ -n "$OPT_TMPDIR" ]; then
      TMPDIR="$OPT_TMPDIR"
      if [ ! -d "$TMPDIR" ]; then
         mkdir $TMPDIR || die "Cannot make $TMPDIR"
      fi
   else
      local tool=`basename $0`
      TMPDIR=`mktemp -d /tmp/${tool}.XXXXX` || die "Cannot make secure tmpdir"
   fi
}

# Sub: rm_TMPDIR
#   Remove the tmpdir and unset TMPDIR.
#
# Optional Global Variables:
#   TMPDIR - TMPDIR set by <set_TMPDIR()>.
#
# Set Global Variables:
#   TMPDIR - Set to "".
rm_TMPDIR() {
   if [ -n "$TMPDIR" ] && [ -d "$TMPDIR" ]; then
      rm -rf $TMPDIR
   fi
   TMPDIR=""
}

# ###########################################################################
# End tmpdir package
# ###########################################################################

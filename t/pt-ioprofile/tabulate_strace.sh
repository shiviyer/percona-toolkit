#!/usr/bin/env bash

TESTS=2

source "$BIN_DIR/pt-ioprofile"

SAMPLES="$T_DIR/samples"

tabulate_strace $SAMPLES/003-samples.txt > $TEST_TMPDIR/got
no_diff \
   $TEST_TMPDIR/got \
   $SAMPLES/003-tab.txt \
   "tabulate 003-samples.txt"

tabulate_strace $SAMPLES/004-samples.txt > $TEST_TMPDIR/got
no_diff \
   $TEST_TMPDIR/got \
   $SAMPLES/004-tab.txt \
   "tabulate 004-samples.txt"

# ###########################################################################
# Done.
# ###########################################################################

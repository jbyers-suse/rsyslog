#!/bin/bash
# added 2016-09-09 by singh.janmejay
# This file is part of the rsyslog project, released under ASL 2.0
. $srcdir/diag.sh init
. $srcdir/diag.sh check-command-available lsof

. $srcdir/diag.sh startup omprog-cleanup.conf
. $srcdir/diag.sh wait-startup
. $srcdir/diag.sh injectmsg  0 5
. $srcdir/diag.sh wait-queueempty
. $srcdir/diag.sh content-check "msgnum:00000000:"
. $srcdir/diag.sh getpid

old_fd_count=$(lsof -p $pid | wc -l)

for i in $(seq 5 10); do
    pkill -USR1 omprog-test-bin
    sleep .1
    . $srcdir/diag.sh injectmsg  $i 1
    sleep .1
done

. $srcdir/diag.sh wait-queueempty
. $srcdir/diag.sh content-check "msgnum:00000009:"

new_fd_count=$(lsof -p $pid | wc -l)
echo OLD: $old_fd_count NEW: $new_fd_count
. $srcdir/diag.sh assert-equal $old_fd_count $new_fd_count 2

. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown
. $srcdir/diag.sh exit

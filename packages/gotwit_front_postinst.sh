#!/bin/bash
set -e # fail on any error
set -u # treat unset variables as errors

# ======[ Trap Errors ]======#
set -E # let shell functions inherit ERR trap

# Trap non-normal exit signals:
# 1/HUP, 2/INT, 3/QUIT, 15/TERM, ERR
trap err_handler 1 2 3 15 ERR
function err_handler {
local exit_status=${1:-$?}
logger -s -p "syslog.err" -t "ootync.deb" "supersh.deb script '$0' error code $exit_status (line $BASH_LINENO: '$BASH_COMMAND')"
exit $exit_status
}

insserv front_d

exit 0

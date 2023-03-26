#!/usr/bin/env bash
###
# File: start-pipewire.sh
# Project: bin
# File Created: Sunday, 26th March 2023 8:02:56 pm
# Author: Bit (me@kumo.dev)
# -----
# Last Modified: Sunday, 26th March 2023 8:02:56 pm
# Modified By: Bit (me@kumo.dev)
###
set -e
source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$pipewire_pid" 2>/dev/null
    kill -TERM "$wireplumber_pid" 2>/dev/null
    kill -TERM "$pipewire_pulse_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT

# CONFIGURE:
export $(dbus-launch)

# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
/usr/bin/pipewire &
pipewire_pid=$!
/usr/bin/pipewire-media-session &
wireplumber_pid=$!
/usr/bin/pipewire-pulse &
pipewire_pulse_pid=$!

wait "$pipewire_pid"
wait "$wireplumber_pid"
wait "$pipewire_pulse_pid"

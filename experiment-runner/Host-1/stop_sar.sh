#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "File name and trial number are required"
  exit 1
fi

FILE_NAME="$1"
TRIAL_NUMBER="$2"

tmux kill-session -t sar-cpu
tmux kill-session -t sar-memory
tmux kill-session -t sar-tcp
tmux kill-session -t sar-udp
tmux kill-session -t sar-sock
tmux kill-session -t sar-ip
tmux kill-session -t sar-q
tmux kill-session -t sar-b
tmux kill-session -t sar-S
tmux kill-session -t sar-w
tmux kill-session -t sar-paging
tmux kill-session -t sar-swap

cd ~/sar/measurements/$TRIAL_NUMBER || exit

# Write log files
sar -u -f cpu-$FILE_NAME > cpu-$FILE_NAME.log
sar -r -f memory-$FILE_NAME > memory-$FILE_NAME.log
sar -n TCP -f tcp-$FILE_NAME > tcp-$FILE_NAME.log
sar -n UDP -f udp-$FILE_NAME > udp-$FILE_NAME.log
sar -n SOCK -f sock-$FILE_NAME > sock-$FILE_NAME.log
sar -n IP -f ip-$FILE_NAME > ip-$FILE_NAME.log
sar -q -f q-$FILE_NAME > q-$FILE_NAME.log
sar -b -f b-$FILE_NAME > b-$FILE_NAME.log
sar -S -f S-$FILE_NAME > S-$FILE_NAME.log
sar -w -f w-$FILE_NAME > w-$FILE_NAME.log
sar -B -f paging-$FILE_NAME > paging-$FILE_NAME.log
sar -W -f swap-$FILE_NAME > swap-$FILE_NAME.log

# Remove sar files
rm cpu-$FILE_NAME
rm memory-$FILE_NAME
rm tcp-$FILE_NAME
rm udp-$FILE_NAME
rm sock-$FILE_NAME
rm ip-$FILE_NAME
rm q-$FILE_NAME
rm b-$FILE_NAME
rm S-$FILE_NAME
rm w-$FILE_NAME
rm paging-$FILE_NAME
rm swap-$FILE_NAME
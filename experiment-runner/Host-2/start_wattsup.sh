#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "$#" -ne 3 ]; then
  echo "File name suffix, trial number and experiment id are required"
  exit 1
fi

FILE_NAME_SUFFIX="$1"
TRIAL_NUMBER="$2"
EXPERIMENT_ID="$3"

cd ~/wattsup/wattsupMeterGL2/ || exit
mkdir -p $EXPERIMENT_ID/$TRIAL_NUMBER

echo "Creating tmux session..."

tmux new -s wattsup -d "cd ~/wattsup/wattsupMeterGL2;
python wattsup.py -l -o $EXPERIMENT_ID/$TRIAL_NUMBER/sample-$(date "+%Y.%m.%d-%H.%M.%S")-$FILE_NAME_SUFFIX.log"

echo "Wattsup started"
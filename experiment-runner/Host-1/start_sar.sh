#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "File name and trial number are required"
  exit 1
fi

FILE_NAME="$1"
TRIAL_NUMBER="$2"

cd ~/sar || exit
mkdir -p measurements/$TRIAL_NUMBER

# Report CPU details
echo "Creating sar-cpu session..."
tmux new -s sar-cpu -d "cd ~/sar;
sar -u 1 -o ~/sar/measurements/$TRIAL_NUMBER/cpu-$FILE_NAME"
echo "sar-cpu started"

# Report about the amount of memory used, amount of memory free, available cache, available buffers
echo "Creating sar-memory session..."
tmux new -s sar-memory -d "cd ~/sar;
sar -r 1 -o ~/sar/measurements/$TRIAL_NUMBER/memory-$FILE_NAME"
echo "sar-memory started"

# Statistics about TCPv4 network traffic
echo "Creating sar-tcp session..."
tmux new -s sar-tcp -d "cd ~/sar;
sar -n TCP 1 -o ~/sar/measurements/$TRIAL_NUMBER/tcp-$FILE_NAME"
echo "sar-tcp started"

# Statistics about UDPv4 network traffic
echo "Creating sar-udp session..."
tmux new -s sar-udp -d "cd ~/sar;
sar -n UDP 1 -o ~/sar/measurements/$TRIAL_NUMBER/udp-$FILE_NAME"
echo "sar-udp started"

# Statistics on sockets in use (IPv4)
echo "Creating sar-sock session..."
tmux new -s sar-sock -d "cd ~/sar;
sar -n SOCK 1 -o ~/sar/measurements/$TRIAL_NUMBER/sock-$FILE_NAME"
echo "sar-sock started"

# Statistics about IPv4 network traffic
echo "Creating sar-ip session..."
tmux new -s sar-ip -d "cd ~/sar;
sar -n IP 1 -o ~/sar/measurements/$TRIAL_NUMBER/ip-$FILE_NAME"
echo "sar-ip started"

# Report run queue length, number of processes and load average
echo "Creating sar-q session..."
tmux new -s sar-q -d "cd ~/sar;
sar -q 1 -o ~/sar/measurements/$TRIAL_NUMBER/q-$FILE_NAME"
echo "sar-q started"

# Report details about I/O operations like transaction per second, read per second, write per second
echo "Creating sar-b session..."
tmux new -s sar-b -d "cd ~/sar;
sar -b 1 -o ~/sar/measurements/$TRIAL_NUMBER/b-$FILE_NAME"
echo "sar-b started"

# Report statistics about swapping
echo "Creating sar-S session..."
tmux new -s sar-S -d "cd ~/sar;
sar -S 1 -o ~/sar/measurements/$TRIAL_NUMBER/S-$FILE_NAME"
echo "sar-S started"

# Report statistics about context switching, number of processes created per second
echo "Creating sar-w session..."
tmux new -s sar-w -d "cd ~/sar;
sar -w 1 -o ~/sar/measurements/$TRIAL_NUMBER/w-$FILE_NAME"
echo "sar-w started"

# Report paging statistics (KBs paged-in/sec, KBs paged-out/sec, pagefault/sec etc.)
echo "Creating sar-B (paging) session..."
tmux new -s sar-paging -d "cd ~/sar;
sar -B 1 -o ~/sar/measurements/$TRIAL_NUMBER/paging-$FILE_NAME"
echo "sar-B started"

# Report swapping statistics
echo "Creating sar-W (swap) session..."
tmux new -s sar-swap -d "cd ~/sar;
sar -W 1 -o ~/sar/measurements/$TRIAL_NUMBER/swap-$FILE_NAME"
echo "sar-W started"

echo "sar running"
#!/usr/bin/env bash

### REF: 'man tmux' && https://gist.github.com/todgru/6224848 ###

# Note: mainly geared towards HTB

### CONCEPT ###
# Setup a workspace named "project1"
# Utilize six different windows (0 - vpn, 1 - scan, 2 - recon, 3 - active, 4 - pcap, 5 - config)
# Window 0 will have an openvpn command ready to fire
# Window 1 will have a combination of nmap/masscan commands ready to fire
# Windows 2-3 will utilize quad-panes
# Window 4 will have a tcpdump command ready to fire

### ALIASES ###
# new-session -> new
# new-window -> neww
# select-window -> selectw
# select-panel -> selectp
# split-window -> splitw
# attach-session -> attach
# C-m -> execute

# project name
project="foxtrot"

# session var
session=$project

# setup working dir
mkdir -p $HOME/htb/$session/{masscan,nmap,pcaps}
cd $HOME/htb/$session

# instantiate tmux
tmux start

# create a new tmux session, specifying the vpn window
tmux new -d -s $session -n vpn

# create a new window called scan
tmux neww -t $session:1 -n scan

# create a new window called recon
tmux neww -t $session:2 -n recon

# create a new window called active
tmux neww -t $session:3 -n active

# create a new window called pcap
tmux neww -t $session:4 -n pcap

# create a new window called config
tmux neww -t $session:5 -n config

# quick mods for scan
tmux selectw -t $session:1
tmux splitw -h
tmux selectp -t 0
tmux splitw -v
tmux selectp -t 2
tmux splitw -v

tmux selectp -t 0
tmux send "masscan 127.0.0.1 -p1-65535,U:1-65535 -oG masscan/masscan_init --rate=1000 -e eth0"
tmux selectp -t 1
tmux send "nmap -sS -Pn --open -p- -T5 -oA nmap/nmap_agg 127.0.0.1"
tmux selectp -t 2
tmux send "nmap -sS -sC -sV -Pn --open -T4 -p80,443 -oA nmap/nmap_init 127.0.0.1"
tmux selectp -t 3
tmux send "nmap -sU --max-retries 2 -T4 --top-ports 200 -oA nmap/nmap_udp 127.0.0.1"

tmux selectp -t 0

# quick mods for recon
tmux selectw -t $session:2
tmux splitw -h
tmux selectp -t 0
tmux splitw -v
tmux selectp -t 2
tmux splitw -v

# quick mods for active
tmux selectw -t $session:3
tmux splitw -h
tmux selectp -t 0
tmux splitw -v
tmux selectp -t 2
tmux splitw -v
tmux selectp -t 0

# setup capture for window 4
tmux selectw -t $session:4
tmux send "tcpdump -i any -w $PWD/pcaps/$project\_1.pcap" C-m

# return to window 1
tmux selectw -t $session:1

# attach to the tmux session
tmux attach -t $session

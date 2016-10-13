#!/bin/bash

sudo ip link set dev tap0 down
sudo ip link set dev br0 down

tunctl -d tap0
brctl delbr br0

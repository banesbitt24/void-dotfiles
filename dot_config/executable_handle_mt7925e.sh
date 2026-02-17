#!/bin/bash

case $1/$2 in
  pre/suspend)
    echo "Removing mt7925e driver before suspend"
    modprobe -r mt7925e
    ;;
  post/suspend)
    echo "Reloading mt7925e driver after suspend"
    modprobe mt7925e
    ;;
esac
#!/usr/bin/env sh
filename=$(ls -l | sort -k6,6n -k7 | awk '{print $6}')
dunstify $ncolor -a "PyWall" "Generating Color ..." -i "~/.config/dunst/icons/hyprdots.png" -r 91190 -t 2500

wall=$(cat ~/.cache/swww/$filename)

Pywall= wal -s -i $wall
waltg= wal-telegram --wal -g -r
#Geenerate pywall
$Pywall
if [ -z $Pywall ] ; then
     $waltg &
     dunstify $ncolor -a "Pywall" "Color Generated ..." -i "~/.config/dunst/icons/hyprdots.png" -r 91190 -t 2500
fi

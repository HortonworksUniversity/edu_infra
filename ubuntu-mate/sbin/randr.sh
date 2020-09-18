#!/bin/bash

PS3="Select a screen Resolution: "

select RES in 1280x720 1366x768 1600x900 1920x1080 2560x1440
do
    xrandr --fb $RES
exit
done

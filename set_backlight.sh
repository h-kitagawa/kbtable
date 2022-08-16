#!/bin/sh
backlight_ctl=/sys/class/backlight/amdgpu_bl0/brightness
backlight=$(( (`cat $backlight_ctl` + ($1) + 8) / 16 * 16 ))
echo $(( $backlight<0 ? 0 : ($backlight>255 ? 255 : $backlight) )) | sudo tee $backlight_ctl


#!/bin/bash

# First step, get to the usb gadget settings dir
cd /sys/kernel/config/usb_gadget/

# the following logic is from https://github.com/larsks/systemd-usb-gadget/
SYSDIR=/sys/kernel/config/usb_gadget/
DEVDIR=${SYSDIR}zynthbox-gadget

[ -d $DEVDIR ] || exit 0

echo '' > $DEVDIR/UDC

echo "Removing strings from configurations"
for dir in $DEVDIR/configs/*/strings/*; do
        [ -d $dir ] && rmdir $dir
done

echo "Removing functions from configurations"
for func in $DEVDIR/configs/*.*/*.*; do
        [ -e $func ] && rm $func
done

echo "Removing configurations"
for conf in $DEVDIR/configs/*; do
        [ -d $conf ] && rmdir $conf
done

echo "Removing functions"
for func in $DEVDIR/functions/*.*; do
        [ -d $func ] && rmdir $func
done

echo "Removing strings"
for str in $DEVDIR/strings/*; do
        [ -d $str ] && rmdir $str
done

echo "Removing gadget"
rmdir $DEVDIR

echo "Done"

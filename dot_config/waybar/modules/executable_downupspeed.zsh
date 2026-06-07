#!/usr/bin/env zsh
# vim: noexpandtab:tabstop=4:shiftwidth=4:textwidth=80
# vim: foldlevel=2:foldmethod=expr

#
#
# ~/.config/waybar/modules/downupspeed.zsh
#
#



IFACE=wlan0

NETDEVOUT=`cat /proc/net/dev | grep $IFACE `
UP=`echo "$NETDEVOUT" | awk '{ print $10 }'`
DOWN=`echo "$NETDEVOUT" | awk '{ print $2 }'`

zmodload zsh/mathfunc

# Converts bits/s to appropriate kB/s or MB/s
function scale() {
	BIT_RATE=$1
	BYTE_RATE=$BIT_RATE/8
	KB_RATE=$BYTE_RATE/1024
	
	if [[ $KB_RATE -gt 1024 ]] ; then
		MB_RATE=$(echo "scale=1; $KB_RATE / 1024" | bc)
		RATE="$MB_RATE M"
	else
		RATE="$KB_RATE K"
	fi

	echo $RATE
}

UP_SCALED=`scale $UP`
DOWN_SCALED=`scale $DOWN`

function pad() {
	DESIRED_WIDTH=6
	TO_PAD=$1
	WIDTH=$(echo "$TO_PAD" | wc -c) 

	while [[ $WIDTH -lt $(($DESIRED_WIDTH+1)) ]]; do 
		TO_PAD=" $TO_PAD"
		WIDTH=$WIDTH+1
	done
	
	echo "$TO_PAD"
}

UP_PADDED=`pad $UP`
DOWN_PADDED=`pad $DOWN`

echo "{\"text\":\"$UP_PADDED $DOWN_PADDED\"}"

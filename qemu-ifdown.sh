#!/bin/sh
set -x

BR_TYPE=ovs  # linux or ovs
BRIDGE=bridge-int
TAP=$1


set -x

if [ -n "$TAP" ]; then
	## del tapx interface from BRIDGE
	if [ "$BR_TYPE" = "linux" ]; then
		ip link set $TAP down
		ip link set $TAP nomaster
		sleep 0.5s
		ip tuntap del $TAP mode tap
	else
		ovs-vsctl del-port $BRIDGE $TAP
	fi

	## Delete BRIDGE if no interface
	if [ "$BR_TYPE" = "linux" ]; then
		IFACES=$(ip link show master $BRIDGE)
	else
		IFACES=$(ovs-vsctl list-ifaces $BRIDGE)
	fi

	if [ $? -eq 0 ] && [ -z "$IFACES" ]; then
		echo "Delete $BRIDGE.."
		if [ "$BR_TYPE" = "linux" ]; then
			ip link del $BRIDGE
		else
			ovs-vsctl del-br $BRIDGE
		fi
	fi
else
        echo "Error: no interface specified"
        exit 1
fi

set +x

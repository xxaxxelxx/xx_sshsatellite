#!/bin/bash
LOOP_SEC=$1
LOADBALANCER_ADDR=$2

test -z $LOOP_SEC && exit;
test -z $LOADBALANCER_ADDR && exit;

while true; do
    test -r files2sync && rm -f files2sync
    OIFS=$IFS; IFS="|"; A_MOUNT=($( ./mountpoints.sh)); IFS=$OIFS
    for M in "${A_MOUNT[@]}"; do
	M=${M#*/}
	echo "intro_$M" >> files2sync
	echo "fallback_$M" >> files2sync
	echo "$M.m3u" >> files2sync
	echo "$M.xspf" >> files2sync
	echo "$M.vclt" >> files2sync
    done
    rsync -a --stats --files-from=files2sync -e 'ssh -p 65522 -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' depot@$LOADBALANCER_ADDR:/depot/ /usr/share/icecast2/web/ | grep -i 'transferred' | grep -w '0' > /dev/null
    if [ $? -ne 0 ]; then
	touch /tmp/icecast.hup.sem
    fi

    sleep $LOOP_SEC
done

exit

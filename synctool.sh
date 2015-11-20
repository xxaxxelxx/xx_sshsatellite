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
    rsync -a --stats --files-from=files2sync -e 'ssh -p 65522 -q -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' depot@$LOADBALANCER_ADDR:/depot/ /usr/share/icecast2/web/ | grep -i 'transferred' | grep -w '0' > /dev/null
    if [ $? -ne 0 ]; then
	touch /tmp/icecast.hup.sem
    fi

    for F_LOG in /var/log/icecast2/*.log.*[[:digit:]]; do
	test -r $F_LOG || continue
	echo $(basename $F_LOG) | grep -i error > /dev/null && rm -f $F_LOG && continue
	gzip $F_LOG > /dev/null
    done
    for GZ_LOG in /var/log/icecast2/*.log.*.gz; do
	test -r $GZ_LOG || continue
	GZ_LOG_NEW="$(dirname $GZ_LOG)/$(md5sum $GZ_LOG | awk '{print $1}').$(basename $GZ_LOG)"
	mv -f $GZ_LOG $GZ_LOG_NEW
	scp -P 65522 -q -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $GZ_LOG_NEW depot@$LOADBALANCER_ADDR:/depot/ > /dev/null
	if [ $? -eq 0 ]; then
	    rm -f $GZ_LOG_NEW
	fi
    done
    sleep $LOOP_SEC
done

exit

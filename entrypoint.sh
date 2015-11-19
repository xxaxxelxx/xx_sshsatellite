#!/bin/bash

# checking the environment
LINKED_CONTAINER=$(env | grep '_ENV_' | head -n 1 | awk '{print $1}' | sed 's/_ENV_.*//')
IC_HOST="$(cat /etc/hosts | grep -iw ${LINKED_CONTAINER} | awk '{print $1}')"
eval IC_PORT=\$${LINKED_CONTAINER}_ENV_IC_PORT
eval IC_ADMIN_PASS=\$${LINKED_CONTAINER}_ENV_IC_ADMIN_PASS


# decrapting rsa_id

echo "$KEY_DECRYPT_PASS" | openssl des3 -d -in /root/.ssh/id_rsa.crypt -out /root/.ssh/id_rsa -pass stdin
chmod 600 /root/.ssh/id_rsa

#./synctool.sh $LOOP_SEC $LOADBALANCER_ADDR $IC_ADMIN_PASS $IC_HOST $IC_PORT
./synctool.sh $LOOP_SEC $LOADBALANCER_ADDR
#bash
exit

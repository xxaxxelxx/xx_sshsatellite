FROM debian:jessie
MAINTAINER xxaxxelxx <x@axxel.net>

#RUN sed -e 's/$/ contrib non-free/' -i /etc/apt/sources.list 

RUN apt-get -qq -y update
#RUN apt-get -qq -y dist-upgrade

ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq -y install mc
RUN apt-get -qq -y install curl
RUN apt-get -qq -y install libxml2-utils
RUN apt-get -qq -y install rsync
RUN apt-get -qq -y install ssh
RUN apt-get -qq -y install netcat-openbsd


# clean up
RUN apt-get clean

ENV IC_ADMIN_PASS='icadminpass'
ENV IC_PORT=80
ENV IC_HOST=127.0.0.1
ENV LOOP_SEC=1
ENV LOADBALANCER_ADDR='192.168.90.29'
ENV MOUNTPOINT_LIST='dummy.mp3'

COPY *.sh /
RUN chmod 700 /*.sh

RUN mkdir /root/.ssh
COPY id_rsa /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
#CMD [ "bash" ]

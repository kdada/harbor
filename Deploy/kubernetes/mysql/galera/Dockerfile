FROM debian:jessie

MAINTAINER me@imkira.com

RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv BC19DDBA &&\
    echo 'deb http://releases.galeracluster.com/debian jessie main' > /etc/apt/sources.list.d/galera.list &&\
    apt-get update &&\
    apt-get install -y python-software-properties &&\
    apt-get install -y galera-3 galera-arbitrator-3 mysql-wsrep-5.6 &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /var/lib/mysql &&\
    mkdir -p /var/lib/mysql &&\
    chown -R mysql:mysql /var/lib/mysql


COPY ./galera.cnf /etc/mysql/conf.d/galera.cnf

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mysqld"]

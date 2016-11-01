#!/bin/bash

# PetSet will set HOSTNAME automatically,on this occasion,you don't need set GALERA_NODE_INDEX
# set GALERA_NODE_INDEX when you are not using PetSet
# examples:
# HOSTNAME=mysql-2
# GALERA_NODE_INDEX=2
# GALERA_CLUSTER_NAME='examples_cluster'
# GALERA_USER_NAME='sst'
# GALERA_USER_PASSWORD='sstpassword'
# GALERA_CLUSTER_ADDRESS='mysql-0,mysql-1,mysql-2'
# GALERA_START_DELAY=5

# configure galera:/etc/mysql/conf.d/galera.cnf
configFile='./galera.cnf'
sed -i "s|^wsrep_cluster_name.*$|wsrep_cluster_name=\"${GALERA_CLUSTER_NAME}\"|g" "${configFile}"
sed -i "s|^wsrep_cluster_address.*$|wsrep_cluster_address=\"gcomm://${GALERA_CLUSTER_ADDRESS}\"|g" ${configFile}
sed -i "s|^wsrep_sst_auth.*$|wsrep_sst_auth=${GALERA_USER_NAME}:${GALERA_USER_PASSWORD}|g" ${configFile}

# get current node index in galera cluster
index=${GALERA_NODE_INDEX:-${HOSTNAME##*-}}
expr ${index} '+' 1000 &> /dev/null
if [ $? -ne 0 ]; then
    echo >&2 'error: start without PetSet and GALERA_NODE_INDEX not set'
    exit 1
fi

# check if the cluster is running
alive=0
check() {
    oldIFS=${IFS}
    IFS=','
    nodes=(${GALERA_CLUSTER_ADDRESS})
    IFS=${oldIFS}
    for node in ${nodes[@]}
    do
        timeout 1 bash -c "</dev/tcp/${node}/3306"
        if [ $? -eq 0 ]; then
            echo 'cluster is alive'
            alive=1
            break
        fi
    done
}

# if the cluster is not alive,try check cluster status every GALERA_START_DELAY seconds
times=${index}
while [ ${times} -ge 0 ]
do
    check()
    if [ ${alive} -ne 0 -o ${times} -eq 0  ]; then
        break
    fi
    sleep ${GALERA_START_DELAY}
    times=$(( ${times} - 1))
done



if [ ${alive} -eq 0 ]; then
    # start a new cluster
    echo "${GALERA_CLUSTER_NAME} is not running,start a new cluster"
    set -- '$@' --wsrep-new-cluster
fi


# if has a initial script,use it   
if [ -f './init.sh' ]; then
    source ./init.sh
fi
 





#!/bin/bash

ROOTDIR=$1
CONFDIR=$2
export ENV=$3
IFS=',' read -r -a TEST_MODULES <<< "$4"

DEPLOYMENTS_KEY='deployments:'

if [[ "$ENV" == "prod" ]]; then
    export MAIN_MODULE="main_prod"
else
    export MAIN_MODULE="main_dev"
fi

. ${CONFDIR}/${ENV}.env

CONF_FILE=${ROOTDIR}/config.yml

envsubst < ${CONFDIR}/template/config_base_template.yml > ${CONF_FILE}

if [ -z ${TEST_MODULES} ]; then
    for d in ${ROOTDIR}/src/coa_idle/tests/*/ ; do
        MODULE=$(basename $d)
        if [[ "$MODULE" == *"tests"* ]]; then
            TEST_MODULES+=($MODULE)
        fi
    done
fi

if (( ${#TEST_MODULES[@]} )); then
    printf "test:\n" >> ${CONF_FILE}
    if grep -q "&args" "$CONF_FILE"; then
        printf "  moduleArgs: *args\n" >> ${CONF_FILE}
    fi
    printf "  modules:\n" >> ${CONF_FILE}
fi

for module in "${TEST_MODULES[@]}"; do
    printf "    - coa_idle.tests.${module}\n" >> ${CONF_FILE}
done

if [ ! -z ${CONTAINER_ID_TESTNET} ]; then
    echo $DEPLOYMENTS_KEY >> ${CONF_FILE}
    envsubst < ${CONFDIR}/template/config_testnet_template.yml >> ${CONF_FILE}
    if [ -z ${BRID_TESTNET} ]; then
        ex -snc '$-1,$d|x' ${CONF_FILE}
    fi
fi

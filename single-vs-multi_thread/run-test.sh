#!/usr/bin/env bash


TYPE=$1
if [ -z "$TYPE"  ]; then
    echo "Please inform the test type. Options: single, multi E.g.: $0 single local"
    exit 1
fi

ENVIRONMENT=$2
if [ -z "$ENVIRONMENT"  ]; then
    echo "Please inform the test environment. Options: local, gce E.g.: $0 single local"
    exit 1
fi

THREADS=2
TEST_TIME=60s
CONNECTIONS_OPEN=100
REQ_PER_SEC=2000
TIMEOUT=5

CPU=102
MEMORY=60

LOG_FILE="${TYPE}_${ENVIRONMENT}_${CPU}cpu_${MEMORY}Mib.log"

echo "Setting up ${TYPE} test at ${ENVIRONMENT} environment with limits ${CPU}cpu/${MEMORY}MibRAM..." > ${LOG_FILE}
cat $LOG_FILE

if [[ "$ENVIRONMENT" == "local" ]]; then
    if [[ "$TYPE" == "single" ]]; then
        PORT=8080
        TAG=svm-single
        DOCKERFILE=Dockerfile_single
    else
        PORT=8081
        TAG=svm-multiple
        DOCKERFILE=Dockerfile_multi
    fi
    docker build -t "$TAG:latest" -f $DOCKERFILE . 1> /dev/null 2> /dev/null
    docker run -d --memory=${MEMORY}Mib --cpu-shares=$CPU -p $PORT:8080 --name $TAG  --rm "$TAG:latest" 1> /dev/null 2> /dev/null
    URL=http://${TAG}.hud:8080/
else
    touch .running
    echo "WARNING: CPU and Memory limits should be configured in Kubernetes"
    if [[ "$TYPE" == "single" ]]; then
        URL=http://kubesbenchsingle.kube.prod.gce.hucloud.com.br/
    else
        URL=http://kubesbenchmulti.kube.prod.gce.hucloud.com.br/
    fi
    TAG=$(kubectl get pods | grep kubesbench$TYPE | cut -d\  -f1)
fi

echo "Stressing $URL with ${THREADS} threads for ${TEST_TIME} of time maintaining ${CONNECTIONS_OPEN} connections opened at ${REQ_PER_SEC}req/sec with ${TIMEOUT}s of timeout" >> ${LOG_FILE}
tail -n1 ${LOG_FILE}

if [[ "$ENVIRONMENT" == "local" ]]; then
    echo -e "CPU\tMemory" > ${LOG_FILE}.csv
    while true; do
        docker stats $TAG --no-stream --format "{{.CPUPerc}}\t{{.MemUsage}}" >> ${LOG_FILE}.csv || break
    done &
else
    SUB_TAG=$(echo $TAG | cut -d-  -f1-2)
    echo -e "CPU\tMemory" > ${LOG_FILE}.csv
    while true; do
        [ -f .running ] && (./kubepodmetric $SUB_TAG -s | cut -f2- -d" " | tr " " \\t)  >> ${LOG_FILE}.csv
        [ -f .running ] || break
        sleep 1
    done &
fi

docker run --entrypoint '' bootjp/wrk2 wrk -t$THREADS -c$CONNECTIONS_OPEN -d$TEST_TIME -R$REQ_PER_SEC --timeout $TIMEOUT --latency $URL >> ${LOG_FILE}


if [[ "$ENVIRONMENT" == "local" ]]; then
    echo -e "\n----------------------------------------------------------\nContainer Logs:" >> ${LOG_FILE}
    docker logs $TAG >> ${LOG_FILE}
else
    rm .running
    echo -e "\n----------------------------------------------------------\nContainer Logs:" >> ${LOG_FILE}
    kubectl logs $TAG >> ${LOG_FILE}
fi

echo -e "\n----------------------------------------------------------\nContainer Stats:" >> ${LOG_FILE}
cat ${LOG_FILE}.csv >> ${LOG_FILE}
rm  ${LOG_FILE}.csv

if [[ "$ENVIRONMENT" == "local" ]]; then
    docker kill $TAG 1> /dev/null 2> /dev/null
fi
#!/usr/bin/env bash
set -xeEo pipefail

source tests/common.sh

function finish {
  if [ $? -eq 1 ] && [ $ERRORED != "true" ]
  then
    error
  fi

  echo "Cleaning up smallfile"
  kubectl delete -f resources/kernel-cache-drop-clusterrole.yaml  --ignore-not-found
  wait_clean
}


trap error ERR
trap finish EXIT

function functional_test_cosbench {
  wait_clean
  apply_operator
  test_name=$1
  cr=$2
  echo "Performing: ${test_name}"
  kubectl apply -f ${cr}
  long_uuid=$(get_uuid 20)
  uuid=${long_uuid:0:8}

  count=0
  while [[ $count -lt 24 ]]; do
    if [[ `kubectl get pods -l app=cosbench-benchmark-$uuid --namespace my-ripsaw -o name | cut -d/ -f2 | grep client` ]]; then
      cosbench_pod=$(kubectl get pods -l app=cosbench-benchmark-$uuid --namespace my-ripsaw -o name | cut -d/ -f2 | grep client)
      count=30
    fi
    if [[ $count -ne 30 ]]; then
      sleep 5
      count=$((count + 1))
    fi
  done
  echo "cosbench_pod ${cosbench_pod}"
  wait_for "kubectl wait --for=condition=Initialized -l app=cosbench-benchmark-$uuid pods --namespace my-ripsaw --timeout=500s" "500s"
  wait_for "kubectl wait --for=condition=complete -l app=cosbench-benchmark-$uuid jobs --namespace my-ripsaw --timeout=100s" "100s"

  indexes="ripsaw-cosbench-results ripsaw-cosbench-rsptimes"
  if check_es "${long_uuid}" "${indexes}"
  then
    echo "${test_name} test: Success"
  else
    echo "Failed to find data for ${test_name} in ES"
    for pod in ${cosbench_pod}; do
      kubectl logs ${pod} --namespace my-ripsaw | grep "RUN STATUS"
    done
    exit 1
  fi
}

figlet $(basename $0)
functional_test_cosbench "cosbench" tests/test_crs/valid_cosbench.yaml

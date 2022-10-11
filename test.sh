#!/bin/bash

# Max amount of time (seconds) to wait for all vulnerabilityreports to show up
# If increasing, may also want to increase successfulJobsHistoryLimit on the cronjobs
# to ensure any problematic job is still available when the problem is detected and
# cronjobs are suspended.
MAXWAIT=60

let count=0
ERRORS=0
while [[ $ERRORS = 0 ]]; do
  kubectl apply -f .
  if [ $? -ne 0 ]; then 
    echo "error applying files"
    exit
  fi

  let elapsed=0
  while [[ $elapsed -lt $MAXWAIT ]]; do
    kubectl get vulnerabilityreports -o jsonpath='{.items[*].metadata.name}' | grep "cronjob-job1-job1 cronjob-job2-job2 cronjob-job3-job3 cronjob-job4-job4 cronjob-job5-job5"
    if [ $? -eq 0 ]; then
      break
    fi
    sleep 5
    let elapsed=$elapsed+5
  done
  if [[ $elapsed -ge $MAXWAIT ]]; then
    echo "$MAXWAIT seconds elapsed without all vulnerabilityreports being generated"
    echo "suspending cronjobs"
    kubectl patch cronjobs job1 job2 job3 job4 job5 -p '{"spec" : {"suspend" : true }}'
    exit
  fi
   
  kubectl delete -f .
  if [ $? -ne 0 ]; then 
    echo "error deleting jobs"
    exit
  fi
  let count=$count+1
  echo "completed $count iterations, last iteration elapsed = $elapsed"
  sleep 10
done

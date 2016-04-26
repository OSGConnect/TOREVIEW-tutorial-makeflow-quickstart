#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: local_condor_makeflow.sh makeflow_file " >&2
  exit 1
fi

FILE=$1
if [ ! -f "$FILE" ]; then
   echo "File $FILE does not exist" >&2
   exit 1
fi

echo "universe    =  local" > local_condor_makeflowjob.submit
echo "getenv      =  true" >> local_condor_makeflowjob.submit
echo "executable  =  /usr/bin/makeflow " >> local_condor_makeflowjob.submit
echo "arguments   =  -T condor $FILE" >> local_condor_makeflowjob.submit
echo "log         =  local_condor.log" >> local_condor_makeflowjob.submit
echo "queue" >> local_condor_makeflowjob.submit

condor_submit local_condor_makeflowjob.submit


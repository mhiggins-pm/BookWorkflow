#!/bin/bash
#
# test_engine
#
# This script sends a ReadyAPI Test Suite to a TestEngine server 
# and reports the status of the tests.
#
# Suitable for ci/cd pipelines (returns exit 1 on any test failure)
#
# This script is not supported by SmartBear Software and is to be used as-is.
#
#   m. higgins    24/02/2021    inital coding (1.0.0)

RELEASE="v1.0.0"
echo " "
echo "test_engine  ${RELEASE} - `date`"

###################################################################################################
# read config file

CONFIG_FILE=$HOME/.swaggerhub-bash.cfg

if [ -f $CONFIG_FILE ]; then
   BUFFER=$(jq -r '.' $CONFIG_FILE)
   IS_SAAS=$(echo $BUFFER | jq -r '.is_saas')
   REGISTRY_FQDN=$(echo $BUFFER | jq -r '.registry_fqdn')
   MANAGEMENT_FQDN=$(echo $BUFFER | jq -r '.management_fqdn')
   ADMIN_FQDN=$(echo $BUFFER | jq -r '.admin_fqdn')
   API_KEY=$(echo $BUFFER | jq -r '.api_key')
   ADMIN_USERNAME=$(echo $BUFFER | jq -r '.admin_username')
   DEFAULT_ORG=$(echo $BUFFER | jq -r '.default_org')
##   TE_USER=
##   TE_FQDN=
else
   echo " "
   echo "No Config file found, please run make_swaggerhub_config.sh"
   exit 1
fi

TE_FQDN="http://testengine:8080/api/v1"

###################################################################################################
# process command line arguements

if [ $# -ne 4 ]
then
   echo " "
   echo "Incorrect command line arguements."
   echo " "
   echo "usage: ./test_engine_functional.sh <te-user> <te-password> <test_type> <project-file>"
   echo " "
   exit 1
fi

TE_USER=$1
TE_PASSWORD=$2
TE_TYPE=$3
PROJECT_FILE=$4

case $TE_TYPE in
   functional) OK=true;;
   security)   OK=true;;
   *)     echo " ";
          echo "<test_type> must be one of functional, security";
          exit 1;;
esac

###################################################################################################
# check for the project file

if [ ! -f $PROJECT_FILE ]; then
   echo " "
   echo "<project-file> not found"
   exit 1;
fi

###################################################################################################
# begin - send the test suite to the testengine

if [ $TE_TYPE == "functional" ]; then
   STRING=$(curl -s -X POST "$TE_FQDN/testjobs?testSuiteName=TestSuite%201" \
                    -H "Content-Type: application/xml"                      \
                    -u "$TE_USER:$TE_PASSWORD"                              \
                    --data-binary "@"$PROJECT_FILE)
   SLEEP_TIME=2

else

   STRING=$(curl -s -X POST "$TE_FQDN/testjobs?securityTestName=SecurityTest%201" \
                    -H "Content-Type: application/xml"                            \
                    -u "$TE_USER:$TE_PASSWORD"                                    \
                    --data-binary "@"$PROJECT_FILE)
   SLEEP_TIME=60

fi

JOBID=$(echo $STRING | jq '.testjobId' | tr -d \")

echo " "
echo "TestEngine jobId : $JOBID"
echo "Test suite in    : $PROJECT_FILE"
echo "Poling time sleep: $SLEEP_TIME"
echo " "

###################################################################################################
# poll the status of the job

STRING=$(curl -s -X GET "$TE_FQDN/testjobs/$JOBID/report" \
                 -H  "accept: application/json"           \
                 -u "$TE_USER:$TE_PASSWORD")

STATUS=$(echo $STRING | jq '.status' | tr -d \")

while [ $STATUS == "RUNNING" ]; do

   STRING=$(curl -s -X GET "$TE_FQDN/testjobs/$JOBID/report" \
                    -H  "accept: application/json"           \
                    -u "$TE_USER:$TE_PASSWORD")

   STATUS=$(echo $STRING | jq '.status' | tr -d \")

   if [ $STATUS == "RUNNING" ]; then
      echo "  status: $STATUS, sleep: $SLEEP_TIME"
      sleep $SLEEP_TIME
   else
      echo "  status: $STATUS"
   fi

done

echo " "

###################################################################################################
# get the detail status of the job steps

STRING=$(curl -s -X GET "$TE_FQDN/testjobs/$JOBID/report" \
                 -H  "accept: application/json"           \
                 -u "$TE_USER:$TE_PASSWORD")

STATUS=$(echo $STRING | jq '.status' | tr -d \")

STRING=($(echo $STRING | jq '.testSuiteResultReports[] | .testCaseResultReports[] | .testStepResultReports[] | .testStepName + ":" + .assertionStatus'))

###################################################################################################
# report and determine overall status for exit

printf "%-5.5s %-30.30s %-6.6s\n" "Step" "Test name" "Status"
printf "%-5.5s %-30.30s %-6.6s\n" "----" "----------------------------" "------"

FAILED="false"

j=0
while [ $j -lt ${#STRING[@]} ]; do

   let i=j+1

   STEP=$(echo ${STRING[$j]}  | cut -d : -f1 | tr -d \")
   STATE=$(echo ${STRING[$j]} | cut -d : -f2 | tr -d \")
 
   if [ $STATE == "FAIL" ]; then
     FAILED="true"
     let k=$i
   fi

   if [ $STATE == "PASS" ]; then
      STATE="pass"
   fi

   printf "%-5.5s %-30.30s %-6.6s\n" " $i" $STEP $STATE

   let j=j+=1

done

###################################################################################################
# report final status and exit

if [ $FAILED == "true" ]; then
   echo " "
   echo "ERROR: Test Suite FAILED at step: $k. -- Exit 1"
   echo " "
   exit 1
else
   echo " "
   echo "INFO: Test Suite Completed $j steps. -- Exit 0"
   echo " "
   exit 0
fi


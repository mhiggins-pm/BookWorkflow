#!/bin/bash
#
# cicd_check_comments
#
# Script to test if there are Cirtical comments errors for an API/Version
#
# The Script uses the SwaggerHub Registry API.
#
# usage: cidi_check_comments <org> <api> <version>
#
# This script is not supported by SmartBear Software and is to be used as-is.
#
#   m. higgins    28/01/2021    inital coding (1.0.0)
#
 
RELEASE="v1.0.0"
echo " "
echo "cicd_check_comments  ${RELEASE} - `date`"

###################################################################################################
# read config file

CONFIG_FILE=./scripts/swaggerhub-bash.cfg

if [ -f $CONFIG_FILE ]; then
   BUFFER=$(jq -r '.' $CONFIG_FILE)
   IS_SAAS=$(echo $BUFFER | jq -r '.is_saas')
   FQDN=$(echo $BUFFER | jq -r '.fqdn')
   REGISTRY_FQDN=$(echo $BUFFER | jq -r '.registry_fqdn')
   MANAGEMENT_FQDN=$(echo $BUFFER | jq -r '.management_fqdn')
   ADMIN_FQDN=$(echo $BUFFER | jq -r '.admin_fqdn')
   API_KEY=$(echo $BUFFER | jq -r '.api_key')
   ADMIN_USERNAME=$(echo $BUFFER | jq -r '.admin_username')
   DEFAULT_ORG=$(echo $BUFFER | jq -r '.default_org')
else
   echo " "
   echo "No Config file found, please run make_swaggerhub_config.sh"
   exit 1
fi

###################################################################################################
# check that jq is installed

if ! jq --help &> /dev/null; then
   echo " "
   echo "The Linux utility jq must be installed to use this script"
   exit 1
fi

######################################################################################################
# process the command line arguements

if [ $# -ne 3 ]
then
   echo " "
   echo "Incorrect command line arguements."
   echo " "
   echo "usage: cidi_check_comments <org> <api> <version>"
   echo " "
   exit 1
fi

ORG=$1
API=$2
VER=$3

###################################################################################################
# check Organization exists AND get the total count of APIs in the Organization

TOTALCOUNT=$(curl -sk -X GET "$REGISTRY_FQDN/apis/$ORG"     \
                      -H "accept: application/json"         \
                      -H "Authorization: Bearer $API_KEY"   \
             | jq '.totalCount')

if [ ${TOTALCOUNT} == null ]; then
   echo " "
   echo "Invalid <organization> or <api-key> entered"
   exit 1
fi

###################################################################################################
# check the API/Verion exists

STRING1=$(curl -sk -X GET "$REGISTRY_FQDN/apis/$ORG/$API/$VER/swagger.json" \
                   -H "accept: application/json"                            \
                   -H "Authorization: Bearer $API_KEY")

TEST=$(echo $STRING1 | jq '.info')

if [ ${#TEST} -lt 10 ]; then
   echo " "
   echo "API/Version not found."
   exit 1
fi

######################################################################################################
# begin

STRING2=$(curl -sk -X GET "$REGISTRY_FQDN/apis/$ORG/$API/$VER/comments"  \
                   -H "accept: application/json"                           \
                   -H "Authorization: Bearer $API_KEY")
   
TEST=$(echo $STRING2 | jq -r '.[].status' | grep OPEN | wc -l)

######################################################################################################
# report

if [ $TEST -gt 0 ];then
   echo " "
   echo "ERROR: $ORG/$API/$VER has $TEST Open Comments. Exit 1"
   echo " "
   exit 1
else
   echo " "
   echo "INFO: $ORG/$API/$VER has NO Open comments. Exit 0"
   echo " "
   exit 0
fi


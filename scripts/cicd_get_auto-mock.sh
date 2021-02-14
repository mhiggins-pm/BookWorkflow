#!/bin/bash
#
# cicd_get_auto-mock
#
# Script to test if the mock payload matchhes an assertion (from a file)
#
# The Script uses the SwaggerHub Registry API.
#
# usage: cidi_get_auto-mock <org> <api> <version> <path> <json|xml> <assertion-file>
#
# This script is not supported by SmartBear Software and is to be used as-is.
#
#   m. higgins    28/01/2021    inital coding (1.0.0)
#   m. higgins    28/01/2021    added handler for xml or json (1.1.0)
#   m. higgins    13/02/2021    added assertion file (1.2.0)
#
 
RELEASE="v1.2.0"
echo " "
echo "cicd_get_auto-mock  ${RELEASE} - `date`"

###################################################################################################
# read config file

CONFIG_FILE=$HOME/.swaggerhub-bash.cfg

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

###################################################################################################
# check that tidy is installed

if ! tidy --version &> /dev/null; then
   echo " "
   echo "The Linux utility tidy must be installed to use this script"
   exit 1
fi

###################################################################################################
# test to see if the SwaggerHub CLI is installed

if swaggerhub --help &> /dev/null; then
   CLI="true"
else
   CLI="false"
fi

###################################################################################################
# process the command line arguements

if [ $# -ne 6 ]
then
   echo " "
   echo "Incorrect command line arguements."
   echo " "
   echo "usage: cidi_get_auto-mock <org> <api> <version> <path> <json|xml> <assertion-file>"
   echo " "
   exit 1
fi

ORG=$1
API=$2
VER=$3
XPATH=$4
APPLICATION=$5
ASSERTION=$6

case $APPLICATION in
   xml) VALID="true";;
   json) VALID="true";;
   *) echo " "
      echo "invalid Application type"
      echo " "
      exit 1;;
esac

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

if [ $CLI == "true" ]; then

   STRING1=$(swaggerhub api:get $ORG/$API/$VER --json)

else

   STRING1=$(curl -sk -X GET "$REGISTRY_FQDN/apis/$ORG/$API/$VER/swagger.json" \
                      -H "accept: application/json"                            \
                      -H "Authorization: Bearer $API_KEY")
fi

TEST=$(echo $STRING1 | jq '.info')

if [ ${#TEST} -lt 10 ]; then
   echo " "
   echo "API/Version not found."
   exit 1
fi

###################################################################################################
# check the assertion file exists

if [ -f $ASSERTION ]; then
   ASSERT=$(cat $ASSERTION)
else
   echo " "
   echo "Assertion file: $ASSERTION not found"
   exit 1
fi

###################################################################################################
# begin

if [ $APPLICATION == "json" ]; then

   STRING2=$(curl -sk -X GET "$FQDN/virts/$ORG/$API/$VER$XPATH"  \
                      -H "accept: application/json"              \
                      -H "Authorization: Bearer $API_KEY")

   MOCK=$(echo $STRING2)

else   

   STRING2=$(curl -sk -X GET "$FQDN/virts/$ORG/$API/$VER$XPATH"  \
                      -H "accept: application/xml"               \
                      -H "Authorization: Bearer $API_KEY")

   MOCK=$(echo $STRING2)

fi

# check the assertion matches the auto-mock payload
   
MOCK_C=$(echo $MOCK | tr -d '\ ')
ASSERT_C=$(echo $ASSERT | tr -d '\ ')

if [ "$MOCK_C" == "$ASSERT_C" ]; then
   echo " "
   echo "INFO: Mock matches Assertion, Exit 0"
   echo " "
   exit 0
else
   echo " "
   echo "ERROR: Mock / Assertion mis-match, Exit 1"
   echo " "
   echo "Mock:"
   echo $MOCK
   echo " "
   echo "Assertion:"
   echo $ASSERT
   echo " "
   exit 1
fi   


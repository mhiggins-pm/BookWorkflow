#!/bin/bash
#
# breaking_changes
#
# Script to test for breaking changes in 2 versions of the same API
#
# The Script uses the SwaggerHub Registry API.
#
# This script is not supported by SmartBear Software and is to be used as-is.
#
#   m. higgins    14/02/2021    inital coding (1.0.0)
#
 
RELEASE="v1.0.0"
echo " "
echo "breaking_changes  ${RELEASE} - `date`"

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
# test to see if the SwaggerHub CLI is installed

if swaggerhub --help &> /dev/null; then
   CLI="true"
else
   CLI="false"
fi

###################################################################################################
# check that jq is installed

if ! jq --help &> /dev/null; then
   echo " "
   echo "The Linux utility jq must be installed to use this script"
   exit 1
fi

###################################################################################################
# check that openapi-diff is installed

if ! npx openapi-diff --help &> /dev/null; then
   echo " "
   echo "openapi-diff must be installed to use this script"
   exit 1
fi

######################################################################################################
# process the command line arguements

if [ $# -ne 6 ]
then
   echo " "
   echo "Incorrect command line arguements."
   echo " "
   echo "usage: breaking_changes <org> <api> <version1> <version2> <proceed:y|n> <report:y|n>"
   echo "   Proceed:"
   echo "      y - exit 0 if there are Breaking Changes"
   echo "      n - exit 1 is there are Beaking Changes"
   echo "   Report:"
   echo "      y - display the full Report"
   echo "      n - no Report is displayed"
   exit 1
fi

ORG=$1
API=$2
VER1=$3
VER2=$4
PROCEED=$5
SHOW=$6

###################################################################################################
# check the Versions are different

if [ $VER1 == $VER2 ]; then
  echo " "
  echo "Cannot compare the same Version"
  exit 1
fi

###################################################################################################
# check the options

case $PROCEED in
   y) VALID="true";;
   n) VALID="true";;
   *) echo " "
      echo "Invalid Proceed option (y|n)"
      exit 1;;
esac

case $SHOW in
   y) VALID="true";;
   n) VALID="true";;
   *) echo " "
      echo "Invalid Report option (y|n)"
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
# check the API/Verion 1 exists

if [ $CLI == "true" ]; then

   STRING1=$(swaggerhub api:get $ORG/$API/$VER1 --json --resolved)

else

   STRING1=$(curl -sk -X GET "$REGISTRY_FQDN/apis/$ORG/$API/$VER1/swagger.json?pretty=false&resolved=true" \
                      -H "accept: application/json"                                                       \
                      -H "Authorization: Bearer $API_KEY")
fi

TEST=$(echo $STRING1 | jq '.info')

if [ ${#TEST} -lt 10 ]; then
   echo " "
   echo "API/Version 1 not found."
   exit 1
fi

echo $STRING1 > _$ORG-$API-$VER1.json
echo " "
echo "   API: _$ORG-$API-$VER1.json - extracted"


###################################################################################################
# check the API/Verion 2 exists

if [ $CLI == "true" ]; then

   STRING1=$(swaggerhub api:get $ORG/$API/$VER2 --json --resolved)

else

   STRING1=$(curl -sk -X GET "$REGISTRY_FQDN/apis/$ORG/$API/$VER2/swagger.json?pretty=false&resolved=true" \
                      -H "accept: application/json"                                                       \
                      -H "Authorization: Bearer $API_KEY")
fi

TEST=$(echo $STRING1 | jq '.info')

if [ ${#TEST} -lt 10 ]; then
   echo " "
   echo "API/Version 2 not found."
   rm _$ORG-$API-$VER1.json
   exit 1
fi

echo $STRING1 > _$ORG-$API-$VER2.json
echo "   API: _$ORG-$API-$VER2.json - extracted"

######################################################################################################
# begin

STRING1=$(npx openapi-diff _$ORG-$API-$VER1.json _$ORG-$API-$VER2.json > _$ORG-$API.txt 2> /dev/null)
REPORT=$(cat _$ORG-$API.txt)

X1=$(cat _$ORG-$API.txt | grep breakingDifferencesFound)
X2="{ $X1 }" # make it json
BREAKING=$(echo $X2 | tr -d ',' | jq '.breakingDifferencesFound')

######################################################################################################
# cleanup

rm _$ORG-$API-$VER1.json
rm _$ORG-$API-$VER2.json
rm _$ORG-$API.txt

######################################################################################################
# report

if [ $SHOW == "y" ]; then
   echo " "
   echo "REPORT:"
   echo "$REPORT"
fi 

######################################################################################################
# end processing

if [ $PROCEED == "n" ]; then
   if [ $BREAKING == "true" ];then
      echo " "
      echo "ERROR: $ORG/$API/$VER2 has Breaking Changes with $VER1 - Exit 1"
      echo " "
      exit 1
   else
      echo " "
      echo "INFO: $ORG/$API/$VER2 has NO Breaking Changes with $VER1 - Exit 0"
      echo " "
      exit 0
   fi
fi

if [ $PROCEED == "y" ]; then
   if [ $BREAKING == "true" ];then 
      echo " "
      echo "WARNING: $ORG/$API/$VER2 has Breaking Changes with $VER1 - Exit 0"
      echo " "
      exit 0
   else
      echo " "
      echo "INFO: $ORG/$API/$VER2 has NO Breaking Changes with $VER1 - Exit 0"
      echo " "
      exit 0
   fi
fi


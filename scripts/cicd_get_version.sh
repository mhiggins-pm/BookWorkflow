#!/bin/bash
#
# cicd_get_version
#
# Script to get the API version from a local yaml or json file
#
# The Script uses the SwaggerHub Registry API.
#
# usage: cidi_get_version <path-to-spec-file>
#
# This script is not supported by SmartBear Software and is to be used as-is.
#
#   m. higgins    18/02/2021    inital coding (1.0.0)
#
 
RELEASE="v1.0.0"
##echo " "
##echo "cicd_get_version  ${RELEASE} - `date`"

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
# process the command line arguements

if [ $# -ne 2 ]
then
   echo " "
   echo "Incorrect command line arguements."
   echo " "
   echo "usage: cidi_get_version <path-to-spec-file> <yaml|json>"
   echo " "
   exit 1
fi

SPECFILE=$1
FTYPE=$2

case $FTYPE in
   
   yaml) VALID="true";;
   json) VALID="true";;
   *) echo " "
      echo "invalid spec file typei <json|yaml>"
      echo " "
      exit 1;;
esac

###################################################################################################
# check the spec file exists

if [ -f $SPECFILE ]; then
   SPEC=$(cat $SPECFILE)
else
   echo " "
   echo "spec file: $SPECFILE not found"
   exit 1
fi

###################################################################################################
# begin

if [ $FTYPE == "yaml" ]; then

   VER=$(cat $SPECFILE | grep 'version:' | cut -d: -f2 | awk '{$1=$1};1')

else   

   VER=$(echo $SPEC | jq '.info.version' | tr -d '\"')
fi

echo "$VER"

exit 0

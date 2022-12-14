#!/bin/sh -l
acruri=$(echo "$1")
clientid=$(echo "$2")
tenantid=$(echo "$3")
if [ -z "$clientid" ]
then
  req=$(echo "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://containerregistry.azure.net")
else
  req=$(echo "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://containerregistry.azure.net&client_id=$clientid")
fi
curl -s -H Metadata:true --noproxy "*" $req >> temp.data
aadtoken=$(grep -o '"access_token":"[^"]*' temp.data | grep -o '[^"]*$')
data="grant_type=access_token&service=$acruri&access_token=$aadtoken"
if ! [ -z "$tenantid" ]
then
  data="$data&tenant=$tenantid"
fi 
url="https://$acruri/oauth2/exchange"
curl --header 'application/x-www-form-urlencoded' -s --insecure --request POST --data $data $url >> temp.data
result=$(grep -o '"refresh_token":"[^"]*' temp.data | grep -o '[^"]*$')
echo $result
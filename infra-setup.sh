#!/bin/bash


AMI_ID="ami-0055977a6e828a4f4"
SG_ID="sg-0e2073a716fbb9bf0"
INSTANCES=("mongodb" "mysql" "redis" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z09395493F0EO6UGSZYVB"
DOMAIN_NAME="yefy.shop"


for instance in "${INSTANCES[@]}"
do

Instance_id=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]')

if [ instance == frontend]
then
ID=$(aws ec2 describe-instances \
    --instance-ids $Instance_id \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)

else
ID=$(aws ec2 describe-instances \
    --instance-ids $Instance_id \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

fi

aws route53 change-resource-record-sets \
    --hosted-zone-id ZONE_ID \
    --change-batch '{
      "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$DOMAIN_NAME'",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [
            {"Value": "'$ID'"}
          ]
        }
      }]
    }'

done
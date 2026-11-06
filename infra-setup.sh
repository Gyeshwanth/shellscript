#!/bin/bash


AMI_ID="ami-0055977a6e828a4f4"
SG_ID="sg-0e2073a716fbb9bf0"
INSTANCES=("mongodb" "mysql" "redis" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z09395493F0EO6UGSZYVB"


$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --count 1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyFirstEC2}]')